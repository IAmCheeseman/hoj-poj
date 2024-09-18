local weapon_common = require("weapon_common")
local StateMachine = require("state_machine")
local Health = require("health")

WalrusFish = struct()

local walrus_fish_shadow = Sprite.create("assets/walrus_fish_shadow.png")
walrus_fish_shadow:offset("center", "center")

function WalrusFish:new()
  self.tags = {"enemy", "demon", "damagable", "soft_coll"}

  self.sprite = Sprite.create("assets/walrus_fish.ase")
  self.sprite:offset("center", "bottom")

  self.x = 0
  self.y = 0

  self.vx = 0
  self.vy = 0

  self.speed = 16
  self.accel = 20

  self.max_attack_timer = 4
  self.attack_timer = 2

  self.body = Body.create(
    self, shape.offsetRect(
      -self.sprite.offsetx, -self.sprite.offsety,
      self.sprite.width, self.sprite.height))

  self.target = world.getSingleton("player")

  self.s_pursue = PursueState:create(self, self.onPursueDirChanged)
  self.s_jump = JumpAttackState:create(self, self.onJumpEnd)
  self.s_jump.jump_before = 64
  self.s_tele_jump = TeleState:create(self, self.s_jump, 1)

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
end

function WalrusFish:damage(attack)
  self.vx = self.vx + attack.kbx
  self.vy = self.vy + attack.kby

  addBloodSplat("demon", self.x, self.y, 3)
end

function WalrusFish:onPursueDirChanged()
  if viewport.isPointOnScreen(self.x, self.y)
  and love.math.random() < 0.2
  and self.attack_timer < 0 then
    self.sm:setState(self.s_tele_jump)
    self.attack_timer = self.max_attack_timer
  end
end

function WalrusFish:onJumpEnd()
  self.sm:setState(self.s_pursue)

  local bullets = 8
  local base_angle = vec.angle(self.vx, self.vy)
  for i=1, bullets do
    local p = (i / bullets * 2) - 1
    local angle = base_angle + p * (math.pi / 2)
    local dirx = math.cos(angle)
    local diry = math.sin(angle)
    world.add(BasicBullet:create({
      x = self.x + dirx * 24,
      y = self.y + diry * 24,
      dirx = dirx * 100,
      diry = diry * 100,
      sprite = weapon_common.enemy_bullet_sprite,
      max_lifetime = 2,
      slow_down = true,
      damage = 1,
      ignore_tags = {"enemy"},
    }))
  end
end

function WalrusFish:step(dt)
  self.sm:call("step", dt)

  self.attack_timer = self.attack_timer - dt

  local pushx, pushy = softCollision(self)
  self.vx = self.vx + pushx * 0.3
  self.vy = self.vy + pushy * 0.3

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt

  self.body:moveAndCollideWithTags({"env"})

  if self.sm.current_state == self.s_jump then
    for _, coll in ipairs(self.body:getAllCollisions({"player"})) do
      local kbx, kby = vec.direction(self.x, self.y, coll.obj.x, coll.obj.y)
      coll.obj.health:takeDamage({
        damage = 2,
        kbx = kbx,
        kby = kby,
      })
    end
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

  local anim = "dwalk"--self.vy < 0 and "uwalk" or "dwalk"
  if vec.lenSq(self.vx, self.vy) < 0.1^2 then
    anim = "didle"--self.vy < 0 and "uidle" or "didle"
  end

  if self.sm.current_state == self.s_tele_jump then
    anim = "dtele"
  end

  if self.health:iFramesActive() then
    anim = "dhurt"--self.vy < 0 and "uhurt" or "dhurt"
  end

  self.sprite:setAnimation(anim)

  walrus_fish_shadow:draw(self.x, self.y)
  self.sprite:draw(self.x, self.y - self.s_jump.jump_height, 0, scale, 1)
end
