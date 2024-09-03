local StateMachine = require("state_machine")
local Health = require("health")

WalrusFish = struct()

function WalrusFish:new()
  self.tags = {"enemy", "demon", "damagable", "soft_coll"}

  self.sprite = Sprite.create("assets/walrus_fish.ase")
  self.sprite:offset("center", "bottom")

  self.shadow = Sprite.create("assets/player_shadow.png")
  self.shadow:offset("center", "center")

  self.x = 0
  self.y = 0

  self.vx = 0
  self.vy = 0

  self.speed = 16
  self.accel = 20

  self.body = Body.create(
    self, shape.offsetRect(
      -self.sprite.offsetx, -self.sprite.offsety,
      self.sprite.width, self.sprite.height))

  self.target = world.getSingleton("player")

  self.s_pursue = PursueState:create(self)

  self.sm = StateMachine.create(self, self.s_pursue)
  self.health = Health.create(self, 40, {
    dead = self.dead,
    damaged = self.damage
  })
end

function WalrusFish:dead(attack)
  world.rem(self)

  self.sprite:setAnimation("dead")
  local corpse = Corpse:create(
    self.sprite, self.body,
    self.x, self.y,
    attack.kbx * 50, attack.kby * 50)
  self.body.anchor = corpse
  world.add(corpse)

  addScore(6, self.x, self.y - self.sprite.height)
  addToKillTimer()
end

function WalrusFish:damage(attack)
  self.vx = self.vx + attack.kbx
  self.vy = self.vy + attack.kby

  addBloodSplat("demon", self.x, self.y, 3)
end

function WalrusFish:step(dt)
  self.sm:call("step", dt)

  local pushx, pushy = softCollision(self)
  self.vx = self.vx + pushx * 0.3
  self.vy = self.vy + pushy * 0.3

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt

  self.body:moveAndCollideWithTags({"env"})

  for _, coll in ipairs(self.body:getAllCollisions({"player"})) do
    local kbx, kby = vec.direction(self.x, self.y, coll.obj.x, coll.obj.y)
    coll.obj.health:takeDamage({
      damage = 5,
      kbx = kbx,
      kby = kby,
    })
  end

  self.z_index = self.y

  self.sprite:update(dt)
end

function WalrusFish:tellTarget(target)
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

function WalrusFish:draw()
  love.graphics.setColor(1, 1, 1)

  local scale = self.vx < 0 and -1 or 1
  local anim = "didle"

  -- local anim = self.vy < 0 and "uwalk" or "dwalk"
  -- if vec.lenSq(self.vx, self.vy) < 0.1^2 then
  --   anim = self.vy < 0 and "uidle" or "didle"
  -- end

  if self.health:iFramesActive() then
    anim = "dhurt"--self.vy < 0 and "uhurt" or "dhurt"
  end

  self.sprite:setAnimation(anim)

  self.shadow:draw(self.x, self.y)
  self.sprite:draw(self.x, self.y, 0, scale, 1)
end
