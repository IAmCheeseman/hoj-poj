local class = require("class")
local core = require("core")
local Event = require("event")

local Health = class()

function Health:init(anchor, maxHealth, sprite)
  self.anchor = anchor
  self.sprite = sprite

  self.damaged = Event()
  self.died = Event()

  if self.sprite then
    self.sprite.drawAL:addStep(self, self.spriteDrawStep)
  end

  self.maxHealth = maxHealth
  self.health = maxHealth
  self.kbResistence = 0
  self.protection = 0

  self.invulnerable = false
  self.iFrames = 0.2
  self.iFramesLeft = 0
end

function Health:update(dt)
  self.iFramesLeft = math.max(self.iFramesLeft - dt, 0)
end

function Health:areIFramesActive()
  return self.iFramesLeft > 0
end

function Health:isInvincible()
  return self.invulnerable or self:areIFramesActive()
end

function Health:takeDamage(damage, kbx, kby)
  local finalDamage = damage
  finalDamage = finalDamage * (1 - self.protection)

  if self.anchor.velx and self.anchor.vely then
    self.anchor.velx = self.anchor.velx + kbx * (1 - self.kbResistence)
    self.anchor.vely = self.anchor.vely + kby * (1 - self.kbResistence)
  end

  if not self:isInvincible() then
    self.health = self.health - finalDamage

    self.damaged:call(damage, self.health, kbx, kby)
    if self.health <= 0 then
      self.died:call()
      core.world:remove(self.anchor)
    end
  end

  self.iFramesLeft = self.iFrames
end

function Health:spriteDrawStep(t)
  local sy = 1 + self.iFramesLeft * 2
  local sx = 1 - (sy - 1)

  t.sx = t.sx * sx
  t.sy = t.sy * sy

  if self.hitAnimation and self:areIFramesActive() then
    t.sprite:setActiveTag(self.hitAnimation)
  end

  return t
end

return Health
