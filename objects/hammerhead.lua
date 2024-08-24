local StateMachine = require("state_machine")
local Health = require("health")

Hammerhead = struct()

function Hammerhead:new()
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
  self.accel = 1/2

  self.aggro_dist = 16 * 6

  self.body = Body.create(
    self, shape.offsetRect(
      -self.sprite.offsetx, -self.sprite.offsety,
      self.sprite.width, self.sprite.height))

  self.s_wander = WanderState:create(self, "player", self.tellTarget)
  self.s_pursue = PursueState:create(self)

  self.sm = StateMachine.create(self, self.s_wander)
  self.health = Health.create(self, 10, {
    dead = self.dead,
    damaged = self.damage
  })
end

function Hammerhead:dead(attack)
  world.rem(self)

  self.sprite:setAnimation("dead")
  self.sprite:update()
  local corpse = Corpse:create(
    self.sprite, self.body,
    self.x, self.y,
    attack.kbx * 2, attack.kby * 2)
  self.body.anchor = corpse
  world.add(corpse)

  addScore(100, self.x, self.y)
end

function Hammerhead:damage(attack)
  self.vx = self.vx + attack.kbx

  addBloodSplat("alien", self.x, self.y, 3)
end

function Hammerhead:step()
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

function Hammerhead:tellTarget(target)
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

function Hammerhead:draw()
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
