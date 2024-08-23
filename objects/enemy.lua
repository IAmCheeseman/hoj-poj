local StateMachine = require("state_machine")
local Health = require("health")

Enemy = struct()

function Enemy:new()
  self.tags = {"enemy", "alien", "damagable", "soft_coll"}

  self.sprite = Sprite.create("assets/hammerhead.ase")
  self.sprite:offset("center", "bottom")

  self.shadow = Sprite.create("assets/player_shadow.png")
  self.shadow:offset("center", "center")

  self.x = 0
  self.y = 0

  self.vx = 0
  self.vy = 0
  self.speed = 2
  self.accel = 1/30

  self.aggro_dist = 16 * 6

  self.body = Body.create(
    self, shape.offsetRect(
      -self.sprite.offsetx, -self.sprite.offsety,
      self.sprite.width, self.sprite.height))

  self.s_wander = {
    step = self.wanderStep,
    timer = 0,
    dir = 0,
  }

  self.s_pursue = {
    step = self.pursueStep,
    timer = 0,
    dir = 0,
  }

  self.sm = StateMachine.create(self, self.s_wander)
  self.health = Health.create(self, 10, {
    dead = self.dead,
    damaged = self.damage
  })
end

function Enemy:dead(attack)
  world.rem(self)

  self.sprite:setAnimation("dead")
  self.sprite:update()
  local corpse = Corpse:create(
    self.sprite, self.body,
    self.x, self.y,
    attack.kbx * 2, attack.kby * 2)
  self.body.anchor = corpse
  world.add(corpse)

  addScore(100)
end

function Enemy:damage(attack)
  self.vx = self.vx + attack.kbx
  self.vy = self.vy + attack.kby

  addBloodSplat("alien", self.x, self.y, 3)
end

function Enemy:step()
  self.sm:call("step")

  local pushx, pushy = softCollision(self)
  self.vx = self.vx + pushx * 0.3
  self.vy = self.vy + pushy * 0.3

  self.x = self.x + self.vx
  self.y = self.y + self.vy

  local coll = self.body:collideWithTags({"env"})
  self.x = self.x + coll.resolvex
  self.y = self.y + coll.resolvey

  self.z_index = self.y
end

function Enemy:tellTarget(target)
  if self.target then
    return
  end

  self.target = target
  self.sm:setState(self.s_pursue)
  world.add(AggroEffect:create(self.x, self.y))

  for _, alien in ipairs(world.getTagged("alien")) do
    if vec.distanceSq(self.x, self.y, alien.x, alien.y) < 64^2 then
      alien:tellTarget(target)
    end
  end
end

function Enemy:wanderStep()
  local target = world.getSingleton("player")
  if not target then
    return
  end

  local dist = vec.distanceSq(self.x, self.y, target.x, target.y)
  if dist < self.aggro_dist^2 then
    self:tellTarget(target)
  end

  -- Wander around
  if self.s_wander.timer <= 0 then
    if love.math.random() < 0.5 then
      self.s_wander.dir = mathx.frandom(0, mathx.tau)
      self.s_wander.timer = love.math.random(15)
    else
      self.s_wander.dir = 0
      self.s_wander.timer = love.math.random(15, 30)
    end
  end

  self.s_wander.timer = self.s_wander.timer - 1

  local dirx, diry = 0, 0
  if self.s_wander.dir ~= 0 then
    dirx, diry =
      math.cos(self.s_wander.dir),
      math.sin(self.s_wander.dir)
  end

  self.vx = mathx.lerp(self.vx, dirx * self.speed, self.accel)
  self.vy = mathx.lerp(self.vy, diry * self.speed, self.accel)
end

function Enemy:pursueStep()
  local tdirx, tdiry = vec.direction(
    self.x, self.y, self.target.x, self.target.y)

  if self.s_pursue.timer <= 0 then
    local chance = 0
    local dir = 0
    local r = 0
    local give_up = 0

    repeat
      dir = mathx.frandom(0, mathx.tau)
      chance = (vec.dot(math.cos(dir), math.sin(dir), tdirx, tdiry) + 1) / 2
      r = love.math.random()
      give_up = give_up + 1
    until r < chance^2 or give_up == 3

    self.s_pursue.dir = dir
    self.s_pursue.timer = love.math.random(15, 20)
  end

  self.s_pursue.timer = self.s_pursue.timer - 1

  local dirx, diry =
      math.cos(self.s_pursue.dir),
      math.sin(self.s_pursue.dir)

  self.vx = mathx.lerp(self.vx, dirx * self.speed, self.accel)
  self.vy = mathx.lerp(self.vy, diry * self.speed, self.accel)
end

function Enemy:draw()
  love.graphics.setColor(1, 1, 1)

  local scale = self.vx < 0 and -1 or 1
  local anim = self.vy < 0 and "uwalk" or "dwalk"
  if vec.lenSq(self.vx, self.vy) < 0.1^2 then
    anim = self.vy < 0 and "uidle" or "didle"
  end

  if self.health:iFramesActive() then
    anim = self.vy < 0 and "uhurt" or "dhurt"
    scale = -scale
  end

  self.sprite:setAnimation(anim)
  self.sprite:update()

  self.shadow:draw(self.x, self.y)
  self.sprite:draw(self.x, self.y, 0, scale, 1)
end
