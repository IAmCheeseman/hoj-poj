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
    self.sprite.transformAL:addStep(self, self.transformSprite)
  end

  self.maxHealth = maxHealth
  self.health = maxHealth
  self.kbResistence = 0
  self.protection = 0
  self.iFrames = 0.1
  self.iFramesLeft = 0
end

function Health:update(dt)
  self.iFramesLeft = math.max(self.iFramesLeft - dt, 0)
end

function Health:takeDamage(damage, kbx, kby)
  self.iFramesLeft = self.iFrames

  local finalDamage = damage
  finalDamage = finalDamage * (1 - self.protection)

  if self.anchor.velx and self.anchor.vely then
    self.anchor.velx = self.anchor.velx + kbx * (1 - self.kbResistence)
    self.anchor.vely = self.anchor.vely + kby * (1 - self.kbResistence)
  end

  self.health = self.health - finalDamage

  self.damaged:call(damage, self.health, kbx, kby)
  if self.health <= 0 then
    self.died:call()
    core.world:remove(self.anchor)
  end
end

function Health:transformSprite(t)
  local sy = 1 + self.iFramesLeft * 2
  local sx = 1 - (sy - 1)

  t.sx = t.sx * sx
  t.sy = t.sy * sy

  return t
end

return Health
