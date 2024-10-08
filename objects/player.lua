local StateMachine = require("state_machine")
local Health = require("health")
local settings = require("settings")
local Slot = require("slot")

Player = struct()

action.define("move_up", {
  {method="key", input="w"},
  {method="jsaxis", input={axis="lefty", dir=-1}},
})
action.define("move_left", {
  {method="key", input="a"},
  {method="jsaxis", input={axis="leftx", dir=-1}},
})
action.define("move_right", {
  {method="key", input="d"},
  {method="jsaxis", input={axis="leftx", dir=1}},
})
action.define("move_down", {
  {method="key", input="s"},
  {method="jsaxis", input={axis="lefty", dir=1}},
})

action.define("pickup", {
  {method="key", input="e"},
  {method="jsbtn", input="a"},
})
action.define("swap", {
  {method="key", input="space"},
  {method="jsbtn", input="leftshoulder"},
})
action.define("fire", {
  {method="mouse", input=1},
  {method="jsbtn", input="rightshoulder"},
})

sound.load("player_hit", "assets/hit.wav", 1)

player_data = {}

function Player:new()
  self.tags = {"player", "damagable"}

  player_data.health.anchor = self
  self.health = player_data.health

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

  self.js_dirx = 0
  self.js_diry = 0
  self.js_tdirx = 0
  self.js_tdiry = 0
  self.cam_accel = 20

  self.s_move = PlayerMove:create(self)
  self.sm = StateMachine.create(self, self.s_move)
end

function Player:added()
  self.weapon = Weapon:create(self, player_data.hand)
  self:updateWeapon()
  world.add(self.weapon)

  local hud = Hud:create(self.health)
  world.add(hud)

  self:updateCamera(false)
end

function Player:dead()
  world.rem(self)
end

function Player:removed()
  world.rem(self.weapon)
end

function Player:damage()
  self.vx = 0
  self.vy = 0

  sound.play("player_hit")
end

function Player:updateWeapon()
  self.weapon.slot = player_data.hand
  self.weapon:reset()
end

function Player:swapWeapons()
  player_data.hand, player_data.offhand = player_data.offhand, player_data.hand
  self:updateWeapon()
end

function Player:autoaim(dirx, diry)
  local base = 0.97
  local autoaim = base + (1 - settings.autoaim) * (1 - base)
  local sel_obj
  local sel_dist = math.huge
  local sel_dot = 0
  local sel_dirx = 0
  local sel_diry = 0

  for _, obj in ipairs(world.getTagged("autoaim_target")) do
    local objx, objy = obj.body:getCenter()
    local odx, ody = vec.direction(self.x, self.y, objx, objy)
    local dist = vec.distance(self.x, self.y, objx, objy)
    local dot = vec.dot(dirx, diry, odx, ody)

    if dot > autoaim and dot > sel_dot and dist < sel_dist
      and viewport.isPointOnScreen(objx, objy) then
      sel_obj = obj
      sel_dot = dot
      sel_dist = dist
      sel_dirx = odx
      sel_diry = ody
    end
  end

  local los = false
  if sel_obj then
    los = not raycast(self.x, self.y, sel_obj.x, sel_obj.y, {"env"}).colliding
  end

  if sel_dirx ~= 0 and sel_diry ~= 0 and los then
    return true, sel_dirx, sel_diry
  end
  return false
end

function Player:updateCamera(lerp, dt)
  local mx, my = getRealPointerPosition()
  mx = mx - self.x
  my = my - self.y
  local camx = self.x - viewport.screenw / 2 + mx * 0.15
  local camy = self.y - viewport.screenh / 2 + my * 0.15

  if lerp then
    local ccamx, ccamy = camera.getPos()
    camera.setPos(
      mathx.dtLerp(ccamx, camx, 15, dt),
      mathx.dtLerp(ccamy, camy, 15, dt))
  else
    camera.setPos(camx, camy)
  end
end

function Player:step(dt)
  if action.using_joystick then
    local dirx = action.getGamepadAxis("rightx")
    local diry = action.getGamepadAxis("righty")
    dirx, diry = vec.normalized(dirx, diry)

    -- Autoaim
    local target, tdirx, tdiry = self:autoaim(dirx, diry)

    if target then
      if tdirx ~= 0 or tdiry ~= 0 then
        self.js_tdirx = tdirx
        self.js_tdiry = tdiry
      end
    else
      if dirx ~= 0 or diry ~= 0 then
        self.js_tdirx = dirx
        self.js_tdiry = diry
      end
    end

    if dirx ~= 0 or diry ~= 0 then
      self.js_dirx = dirx
      self.js_diry = diry
    end

    setRealPointerPosition(
      self.x + self.js_dirx * 64,
      self.y + self.js_diry * 64)
    setPointerPosition(
      self.x + self.js_tdirx * 64,
      self.y + self.js_tdiry * 64)
  else
    setRealPointerPosition(getWorldMousePosition())
    setPointerPosition(getWorldMousePosition())
  end

  self.sm:call("step", dt)

  self.body:moveAndCollideWithTags(self.vx, self.vy, dt, {"env"})

  self.z_index = self.y

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
      local cslot = closest.slot

      local handled = false

      for _, slot in ipairs({player_data.hand, player_data.offhand}) do
        if cslot.weapon == slot.weapon then
          if slot.dual_wielding then
            cslot.dual_wielding = false
          elseif not slot.dual then
            cslot.weapon = nil
          end
          slot.dual_wielding = true
          handled = true
        end
      end

      if not handled then
        if player_data.offhand:isEmpty() then
          self:swapWeapons()
        end

        player_data.hand, closest.slot = cslot, player_data.hand

        self:updateWeapon()
      end
    end
  end

  if getKillTimer() <= 0 then
    player_data.health:kill()
  end

  -- Update graphics
  do
    local mx, my = getPointerPosition()
    self.scalex = mx < self.x and -1 or 1

    local anim = my < self.y and "uwalk" or "dwalk"
    if vec.lenSq(self.vx, self.vy) < 5^2 then
      anim = my < self.y and "uidle" or "didle"
    end

    if player_data.health:iFramesActive() then
      anim = "hurt"
    end

    self.sprite:setAnimation(anim)
    self.sprite:update(dt)
  end

  self:updateCamera(true, dt)
end

function Player:draw()
  love.graphics.setColor(1, 1, 1)
  self.shadow:draw(self.x, self.y)
  self.sprite:draw(self.x, self.y, 0, self.scalex, 1)
end

function resetPlayerData()
  player_data.hand = Slot.create("pistol")
  player_data.offhand = Slot.create(nil)

  player_data.health = Health.create(nil, 5, {
    dead = Player.dead,
    damaged = Player.damage,
  })
  player_data.health.iframes_prevent_damage = true
end

resetPlayerData()
