local weapons = require("weapons")
local ui = require("ui")

Player = struct()

action.define("move_up", "key", "w")
action.define("move_left", "key", "a")
action.define("move_down", "key", "s")
action.define("move_right", "key", "d")
action.define("pickup", "key", "e")
action.define("swap", "key", "space")
action.define("fire", "mouse", 1)

ammo = {
  bullets = {
    amount = 32,
    kit_amount = 20,
    max = 256
  },
  shells = {
    amount = 24,
    kit_amount = 6,
    max = 64
  },
}

function Player:new()
  self.tags = {"player", "soft_coll"}

  self.sprite = Sprite.create("assets/player.ase")
  self.sprite:offset("center", "bottom")
  self.sprite.layers["hands"].visible = false

  self.shadow = Sprite.create("assets/player_shadow.png")
  self.shadow:offset("center", "center")

  self.x = 0
  self.y = 0

  self.body = Body.create(self, shape.offsetEllipse(0, -2, 5, 2))

  self.vx = 0
  self.vy = 0

  self.speed = 3
  self.frict = 0.45

  self.cam_accel = 1/3

  self.hand = "pistol"
  self.offhand = "shotgun"

  self.weapon = Weapon:create(self, self.hand)
  world.add(self.weapon)
end

function Player:removed()
  world.rem(self.weapon)
end

function Player:swapWeapons()
  local temp = self.hand
  self.hand = self.offhand
  self.offhand = temp

  self.weapon.type = self.hand
  self.weapon:reset()
end

function Player:step()
  local ix, iy = 0, 0
  if action.isDown("move_up")    then iy = iy - 1 end
  if action.isDown("move_left")  then ix = ix - 1 end
  if action.isDown("move_down")  then iy = iy + 1 end
  if action.isDown("move_right") then ix = ix + 1 end

  ix, iy = vec.normalized(ix, iy)
  local nvx, nvy = vec.normalized(self.vx, self.vy)

  accel_delta = self.frict

  self.vx = mathx.lerp(self.vx, ix * self.speed, accel_delta)
  self.vy = mathx.lerp(self.vy, iy * self.speed, accel_delta)

  local pushx, pushy = softCollision(self)
  self.vx = self.vx + pushx * 0.3
  self.vy = self.vy + pushy * 0.3

  self.x = self.x + self.vx
  self.y = self.y + self.vy

  local coll = self.body:collideWithTags({"env"})
  self.x = self.x + coll.resolvex
  self.y = self.y + coll.resolvey

  self.z_index = self.y

  camera.setPos(
    mathx.lerp(
      viewport.camx, self.x - viewport.screenw / 2, self.cam_accel),
    mathx.lerp(
      viewport.camy, self.y - viewport.screenh / 2, self.cam_accel))

  if action.isJustDown("swap") then
    self:swapWeapons()
  end

  local closest = nil
  local closest_dist = math.huge
  for _, drop in ipairs(world.getTagged("dropped_weapon")) do
    local dist = vec.distanceSq(self.x, self.y, drop.x, drop.y)
    drop.can_pickup = false
    if dist < 16^2 and dist < closest_dist then
      closest = drop
      closest_dist = dist
    end
  end

  if closest then
    closest.can_pickup = true

    if action.isJustDown("pickup") then
      local temp = closest.type
      closest.type = self.hand
      self.hand = temp

      self.weapon.type = self.hand
      self.weapon:reset()
    end
  end
end

function Player:draw()
  love.graphics.setColor(1, 1, 1)

  local mx, my = getWorldMousePosition()

  local scale = mx < self.x and -1 or 1

  local anim = my < self.y and "uwalk" or "dwalk"
  if vec.lenSq(self.vx, self.vy) < 0.1^2 then
    anim = my < self.y and "uidle" or "didle"
  end

  self.sprite:setAnimation(anim)
  self.sprite:update()

  self.shadow:draw(self.x, self.y)
  self.sprite:draw(self.x, self.y, 0, scale, 1)
end

local function pad0(str, zeros)
  local to_add = math.max(zeros - #str, 0)
  for _=1, to_add do
    str = "0" .. str
  end
  return str
end

function Player:gui()
  love.graphics.setFont(ui.hud_font)
  local texty = viewport.screenh - ui.hud_font:getHeight() * 1.25

  do -- Score
    local combo_time, max_combo_time = getComboTime()
    local comboy = texty - 3
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 1, comboy, 64, 2)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 1, comboy, 64 * (combo_time / max_combo_time), 2)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
      {
        {1, 1, 1}, tr("hud_score") .. " ",
        {1, 1, 0}, pad0(tostring(getScore()), 7),
        {0, 1, 0}, " *" .. tostring(getCombo()),
      },
      1, texty,
      viewport.screenw, "left")
  end

  do -- HP
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
      {
        {1, 1, 1}, tr("hud_hp") .. " ",
        {1, 0, 0}, pad0("20", 2),
        {1, 1, 1}, "/",
        {0.5, 0.5, 0.5}, "20",
      },
      0, texty,
      viewport.screenw, "center")
  end

  do -- Weapons
    local limit = 48 / 2

    local first = weapons[self.hand]
    local other = weapons[self.offhand]

    local first_name = tr(first.name)
    local other_name = tr(other.name)
    local first_ammo = tostring(ammo[first.ammo].amount)
    local other_ammo = tostring(ammo[other.ammo].amount)

    local first_text = first_name .. " " .. first_ammo
    local other_text = other_name .. " " .. other_ammo

    local first_width = math.max(ui.hud_font:getWidth(first_text) + 2, limit)
    local other_width = math.max(ui.hud_font:getWidth(other_text) + 2, limit)

    local firstx = viewport.screenw - other_width - first_width
    local otherx = viewport.screenw - other_width

    love.graphics.printf(
      {
        {1, 1, 1}, first_name .. " ",
        {1, 1, 0}, first_ammo,
      },
      firstx, texty, first_width, "center")

    love.graphics.printf(
      {
        {0.5, 0.5, 0.5}, other_name .. " ",
        {0.6, 0.4, 0}, other_ammo,
      },
      otherx, texty, other_width, "center")
  end
end
