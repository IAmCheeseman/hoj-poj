local weapon_common = require("weapon_common")
local StateMachine = require("state_machine")
local Health = require("health")

ShootyEnemy = struct()

function ShootyEnemy:new()
  self.tags = {"enemy", "soft_coll", "damagable"}

  self.x = 0
  self.y = 0

  self.vx = 0
  self.vy = 0

  self.speed = 32
  self.accel = 20

  self.body = Body.create(self, shape.rect(16, 16))

  self.target = world.getSingleton("player")

  self.s_pursue = PursueState:create(self, self.onPursueDirection)
  self.s_pursue.pursue_time_min = 1
  self.s_pursue.pursue_time_max = 1.5
  self.s_idle = IdleState:create(self, self.onIdle, self.onIdleTimerOver)

  self.sm = StateMachine.create(self, self.s_pursue)
  self.health = Health.create(self, 13, {
    dead = self.dead,
    -- damaged = self.damage
  })
end

function ShootyEnemy:onPursueDirection()
  if viewport.isPointOnScreen(self.x, self.y) then
    self.sm:setState(self.s_idle)
  end
end

function ShootyEnemy:onIdleTimerOver()
  self.sm:setState(self.s_pursue)

  weapon_common.singleFire({
    ignore_tags = {"enemy"},
    speed = 100,
    x = self.x,
    y = self.y,
    angle = vec.angleBetween(self.x, self.y, self.target.x, self.target.y),
    damage = 7,
    sprite = weapon_common.enemy_bullet_sprite,
  })
end

function ShootyEnemy:dead()
  world.rem(self)

  addScore(5, self.x, self.y)
  addToKillTimer()
end

function ShootyEnemy:step(dt)
  self.sm:call("step", dt)

  local pushx, pushy = softCollision(self)
  self.vx = self.vx + pushx * 0.3
  self.vy = self.vy + pushy * 0.3

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt

  self.body:moveAndCollideWithTags({"env"})

  self.z_index = self.y
end

function ShootyEnemy:draw()
  love.graphics.rectangle("fill", self.x, self.y, 16, 16)
end
