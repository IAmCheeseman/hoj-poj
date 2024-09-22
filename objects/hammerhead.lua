local StateMachine = require("state_machine")
local Health = require("health")

Hammerhead = struct()

addEnemyToSpawner(Hammerhead, 1, 1)

function Hammerhead:new()
  self.tags = {"enemy", "alien", "damagable", "soft_coll", "autoaim_target"}

  self.sprite = Sprite.create("assets/hammerhead.ase")
  self.sprite:offset("center", "bottom")

  self.shadow = Sprite.create("assets/player_shadow.png")
  self.shadow:offset("center", "center")

  self.x = 0
  self.y = 0

  self.vx = 0
  self.vy = 0

  self.speed = 52
  self.accel = 20

  self.body = Body.create(self, shape.offsetRect(-6, -12, 12, 12))

  self.target = world.getSingleton("player")

  self.s_pursue = PursueState:create(self)

  self.sm = StateMachine.create(self, self.s_pursue)
  self.health = Health.create(self, 6, {
    dead = self.dead,
    damaged = self.damage
  })
end

function Hammerhead:dead(attack)
  world.rem(self)

  self.sprite:setAnimation("dead")
  local corpse = Corpse:create(
    self.sprite, self.body,
    self.x, self.y,
    attack.kbx * 100, attack.kby * 100)
  self.body.anchor = corpse
  world.add(corpse)
end

function Hammerhead:damage(attack)
  self.vx = self.vx + attack.kbx
  self.vy = self.vy + attack.kby

  addBloodSplat("alien", self.x, self.y, 3)
end

function Hammerhead:step(dt)
  self.sm:call("step", dt)

  local pushx, pushy = softCollision(self)
  self.vx = self.vx + pushx * 0.3
  self.vy = self.vy + pushy * 0.3

  for _, coll in ipairs(
      self.body:getAllCollisions(self.vx, self.vy, dt, {"player"})) do
    local kbx, kby = vec.direction(self.x, self.y, coll.obj.x, coll.obj.y)
    coll.obj.health:takeDamage({
      damage = 1,
      kbx = kbx,
      kby = kby,
    })
  end

  self.body:moveAndCollideWithTags(self.vx, self.vy, dt, {"env"})

  self.z_index = self.y

  self.sprite:update(dt)
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

  self.shadow:draw(self.x, self.y)
  self.sprite:draw(self.x, self.y, 0, scale, 1)
end
