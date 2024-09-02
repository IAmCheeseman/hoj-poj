local weapon_common = require("weapon_common")
local StateMachine = require("state_machine")
local Health = require("health")

sound.load("redneck_gunner_shoot", "assets/redneck_gunner_shoot.wav")

RedneckGunner = struct()

function RedneckGunner:new()
  self.tags = {"enemy", "soft_coll", "damagable"}

  self.sprite = Sprite.create("assets/redneck_gunner.ase")
  self.sprite:offset("center", "bottom")

  self.pistol = Sprite.create("assets/pistol.png")
  self.pistol:offset(-5, "center")
  self.pistol_height = 4
  self.pistol_rot = 0

  self.shadow = Sprite.create("assets/player_shadow.png")
  self.shadow:offset("center", "center")

  self.x = 0
  self.y = 0

  self.vx = 0
  self.vy = 0

  self.speed = 32
  self.accel = 20

  self.body = Body.create(
    self, shape.offsetRect(
      -self.sprite.offsetx, -self.sprite.offsety,
      self.sprite.width, self.sprite.height))

  self.target = world.getSingleton("player")

  self.s_pursue = PursueState:create(self, self.onPursueDirection)
  self.s_pursue.pursue_time_min = 1
  self.s_pursue.pursue_time_max = 1.5
  self.s_idle = IdleState:create(self, self.onIdle, self.onIdleTimerOver)

  self.sm = StateMachine.create(self, self.s_pursue)
  self.health = Health.create(self, 13, {
    dead = self.dead,
    damaged = self.damage
  })
end

function RedneckGunner:onPursueDirection()
  if viewport.isPointOnScreen(self.x, self.y) then
    self.sm:setState(self.s_idle)
  end
end

function RedneckGunner:onIdleTimerOver()
  self.sm:setState(self.s_pursue)

  local angle = vec.angleBetween(
    self.x, self.y - self.pistol_height,
    self.target.x, self.target.y)
  self.pistol_rot = angle
  weapon_common.singleFire({
    ignore_tags = {"enemy"},
    speed = 100,
    x = self.x + math.cos(angle) * 8,
    y = self.y + math.sin(angle) * 8 - self.pistol_height,
    angle = angle,
    damage = 7,
    sprite = weapon_common.enemy_bullet_sprite,
  })
  sound.play("redneck_gunner_shoot", true)
end

function RedneckGunner:dead(attack)
  world.rem(self)

  self.sprite:setAnimation("dead")
  local corpse = Corpse:create(
    self.sprite, self.body,
    self.x, self.y,
    attack.kbx * 100, attack.kby * 100)
  self.body.anchor = corpse
  world.add(corpse)

  addScore(5, self.x, self.y)
  addToKillTimer()
end

function RedneckGunner:damage(attack)
  self.vx = self.vx + attack.kbx
  self.vy = self.vy + attack.kby

  addBloodSplat("earthling", self.x, self.y, 3)
end

function RedneckGunner:step(dt)
  self.sm:call("step", dt)

  if self.sm.current_state == self.s_idle then
    local angle = vec.angleBetween(
      self.x, self.y - self.pistol_height,
      self.target.x, self.target.y)
    self.pistol_rot = angle
    self.sprite_scale = self.target.x < self.x and -1 or 1
  elseif self.sm.current_state == self.s_pursue then
    self.pistol_rot = vec.angle(self.vx, self.vy)
    self.sprite_scale = self.vx < 0 and -1 or 1
  end

  local pushx, pushy = softCollision(self)
  self.vx = self.vx + pushx * 0.3
  self.vy = self.vy + pushy * 0.3

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt

  self.body:moveAndCollideWithTags({"env"})

  self.z_index = self.y

  self.sprite:update(dt)
end

function RedneckGunner:draw()
  love.graphics.setColor(1, 1, 1)

  -- TODO: this code is basically the same between the player, hammerhead, and
  -- this. Abstract it out.
  local anim = self.vy < 0 and "uwalk" or "dwalk"
  if vec.lenSq(self.vx, self.vy) < 5^2 then
    anim = self.vy < 0 and "uidle" or "didle"
  end

  if self.health:iFramesActive() then
    anim = self.vy < 0 and "uhurt" or "dhurt"
    self.sprite_scale = -self.sprite_scale
  end

  self.sprite:setAnimation(anim)
  self.shadow:draw(self.x, self.y)
  self.sprite:draw(self.x, self.y, 0, self.sprite_scale, 1)
  self.pistol:draw(self.x, self.y - self.pistol_height, self.pistol_rot)
end
