local class = require("class")
local core = require("core")

local Health = class()

local flash = love.graphics.newShader("vfx/flash.frag")

function Health:init(anchor, maxHealth)
  self.anchor = anchor

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
  if self.health <= 0 then
    core.world:remove(self.anchor)
  end
end

function Health:drawSprite(sprite, x, y, r, sx, sy, kx, ky)
  love.graphics.setColor(1, 1, 1)

  sx = sx or 1
  sy = sy or sx

  sy = sy * (1 + self.iFramesLeft * 2)
  sx = sx * (1 - (sy - 1))

  flash:send("amount", math.ceil(self.iFramesLeft))

  love.graphics.setShader(flash)
  sprite:draw(x, y, r, sx, sy, kx, ky)
  love.graphics.setShader()
end

return Health
