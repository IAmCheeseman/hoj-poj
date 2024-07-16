local class = require("class")
local Chunker = require("physics.chunker")

local PhysicsWorld = class()

function PhysicsWorld:init(gridSize, partitionCount)
  gridSize = gridSize or (128 * 2)
  partitionCount = partitionCount or 64

  self.chunker = Chunker(gridSize, partitionCount)
end

function PhysicsWorld:addBody(body)
  body:i_setWorld(self)
  self.chunker:addBody(body)
end

function PhysicsWorld:getMaxBodySize()
  return self.chunker.size
end

function PhysicsWorld:draw()
  love.graphics.setColor(1,1,1)
  for x=-20, 20 do
    for y=-20, 20 do
      local dx = x * self.chunker.size
      local dy = y * self.chunker.size
      love.graphics.rectangle("line", dx, dy, self.chunker.size, self.chunker.size)
    end
  end

  for body, _ in pairs(self.chunker.bodies) do
    love.graphics.setColor(body:getColor())
    local x, y = body:getPosition()
    love.graphics.rectangle("fill", x, y, body.w, body.h)
  end
  love.graphics.setColor(1, 1, 1)
end

return PhysicsWorld
