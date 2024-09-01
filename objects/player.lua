local weapons = require("weapons")
local ui = require("ui")
local Health = require("health")

Player = struct()

action.define("move_up", "key", "w")
action.define("move_left", "key", "a")
action.define("move_down", "key", "s")
action.define("move_right", "key", "d")
action.define("pickup", "key", "e")
action.define("swap", "key", "space")
action.define("fire", "mouse", 1)

sound.load("player_hit", "assets/hit.wav", 1)

ammo = {
  bullets = {
    name = "ammo_bullets",
    amount = 32,
    crate_amount = 20,
    max = 256
  },
  shells = {
    name = "ammo_shells",
    amount = 24,
    crate_amount = 6,
    max = 64
  },
}

function Player:new()
  self.tags = {"player", "damagable"}

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

  self.speed = 16 * 6
  self.frict = 12

  self.cam_accel = 20

  self.hand = "pistol"
  self.offhand = "shotgun"

  self.health = Health.create(self, 20, {
    dead = self.dead,
    damaged = self.damage
  })

  self.health.iframes_prevent_damage = true
end

function Player:added()
  self.weapon = Weapon:create(self, self.hand)
  world.add(self.weapon)
  world.addChildTo(self, self.weapon)
end

function Player:dead()
  self.draw = function() end
  self.step = function() end
  world.rem(self.weapon)
end

function Player:damage()
  self.vx = 0
  self.vy = 0

  sound.play("player_hit")
end

function Player:swapWeapons()
  local temp = self.hand
  self.hand = self.offhand
  self.offhand = temp

  self.weapon.type = self.hand
  self.weapon:reset()
end

function Player:step(dt)
  local ix, iy = 0, 0
  if action.isDown("move_up")    then iy = iy - 1 end
  if action.isDown("move_left")  then ix = ix - 1 end
  if action.isDown("move_down")  then iy = iy + 1 end
  if action.isDown("move_right") then ix = ix + 1 end

  ix, iy = vec.normalized(ix, iy)

  self.vx = mathx.dtLerp(self.vx, ix * self.speed, self.frict, dt)
  self.vy = mathx.dtLerp(self.vy, iy * self.speed, self.frict, dt)

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt

  self.body:moveAndCollideWithTags({"env"})

  self.z_index = self.y

  -- Update camera
  do
    local mx, my = getWorldMousePosition()
    mx = mx - self.x
    my = my - self.y
    local camx = self.x - viewport.screenw / 2 + mx * 0.15
    local camy = self.y - viewport.screenh / 2 + my * 0.15
    camera.setPos(camx, camy)
  end

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

  if getKillTimer() <= 0 then
    self.health:kill()
  end

  -- Update graphics
  do
    local mx, my = getWorldMousePosition()
    self.scalex = mx < self.x and -1 or 1

    local anim = my < self.y and "uwalk" or "dwalk"
    if vec.lenSq(self.vx, self.vy) < 5^2 then
      anim = my < self.y and "uidle" or "didle"
    end

    if self.health:iFramesActive() then
      anim = "hurt"
    end

    self.sprite:setAnimation(anim)
    self.sprite:update(dt)
  end
end

function Player:draw()
  love.graphics.setColor(1, 1, 1)
  self.shadow:draw(self.x, self.y)
  self.sprite:draw(self.x, self.y, 0, self.scalex, 1)
end

local function pad0(str, zeros)
  local to_add = math.max(zeros - #str, 0)
  str = ("0"):rep(to_add) .. str
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
        {1, 0, 0}, pad0(tostring(self.health.hp), 2),
        {1, 1, 1}, "/",
        {0.5, 0.5, 0.5}, tostring(self.health.max_hp),
      },
      0, texty,
      viewport.screenw, "center")
  end

  do -- Timer
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
      {
        {1, 1, 1}, tr("hud_time") .. " ",
        {0, 1, 0.5}, pad0(tostring(getKillTimer()), 2),
      },
      0, texty - ui.hud_font:getHeight(),
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

  if self.health.dead then
    local centery = viewport.screenh / 2 - ui.hud_font:getHeight() / 2
    love.graphics.printf(
      {
        {1, 1, 1}, "Thou hast",
        {1, 0, 0}, " perishedeth",
        {1, 1, 1}, ".",
      },
      0, centery, viewport.screenw, "center")
  end
end
