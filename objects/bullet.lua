local object = require("object")
local shadow = require("shadow")
local core = require("core")

local Bullet = object()

function Bullet:init(x, y, rot, speed)
  self.x = x
  self.y = y
  self.rot = rot
  self.speed = speed

  self.lifetime = 5
end

function Bullet:update(dt)
  self.x = self.x + math.cos(self.rot) * self.speed * dt
  self.y = self.y + math.sin(self.rot) * self.speed * dt

  self.zIndex = self.y + 5

  self.lifetime = self.lifetime - dt

  if self.lifetime < 0 then
    core.world:remove(self)
  end

  shadow.queueDraw(2, self.x, self.y + 5)
end

function Bullet:draw()
  love.graphics.setColor(1, 1, 0)
  love.graphics.circle("fill", self.x, self.y, 2)
end

return Bullet
