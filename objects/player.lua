local Health = require("health")

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
  {method="jsbtn", input="b"},
})
action.define("fire", {
  {method="mouse", input=1},
  {method="jsaxis", input={axis="triggerright", dir=1}},
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

  self.cam_accel = 20
end

function Player:added()
  self.weapon = Weapon:create(self, player_data.hand)

  world.add(self.weapon)

  local hud = Hud:create(self.health)
  world.add(hud)
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

function Player:swapWeapons()
  local temp = player_data.hand
  player_data.hand = player_data.offhand
  player_data.offhand = temp

  self.weapon.type = player_data.hand
  self.weapon:reset()
end

function Player:step(dt)
  if action.using_joystick then
    local dirx = action.joystick:getGamepadAxis("rightx")
    local diry = action.joystick:getGamepadAxis("righty")
    dirx, diry = vec.normalized(dirx, diry)
    setPointerPosition(
      self.x + dirx * 64,
      self.y + diry * 64)
  else
    setPointerPosition(getWorldMousePosition())
  end

  local ix, iy = 0, 0
  if action.isDown("move_up")    then iy = iy - 1 end
  if action.isDown("move_left")  then ix = ix - 1 end
  if action.isDown("move_down")  then iy = iy + 1 end
  if action.isDown("move_right") then ix = ix + 1 end

  self.sprite.layers["hands"].visible = not player_data.hand

  ix, iy = vec.normalized(ix, iy)

  self.vx = mathx.dtLerp(self.vx, ix * self.speed, self.frict, dt)
  self.vy = mathx.dtLerp(self.vy, iy * self.speed, self.frict, dt)

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt

  self.body:moveAndCollideWithTags({"env"})

  self.z_index = self.y

  -- Update camera
  do
    local mx, my = getPointerPosition()
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
      local hand = "offhand"
      if player_data[hand] then
        hand = "hand"
      end

      closest.type = player_data[hand]
      player_data[hand] = temp

      if hand == "hand" then
        self.weapon.type = player_data[hand]
        self.weapon:reset()
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
end

function Player:draw()
  love.graphics.setColor(1, 1, 1)
  self.shadow:draw(self.x, self.y)
  self.sprite:draw(self.x, self.y, 0, self.scalex, 1)
end

function resetPlayerData()
  player_data.hand = "pistol"
  player_data.offhand = nil

  player_data.health = Health.create(nil, 5, {
    dead = Player.dead,
    damaged = Player.damage,
  })
  player_data.health.iframes_prevent_damage = true
end

resetPlayerData()
