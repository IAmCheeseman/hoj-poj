local class = require("class")
local Chunker = require("physics.chunker")

local PhysicsWorld = class()

function PhysicsWorld:init(gridSize, partitionCount)
  gridSize = gridSize or (128 * 2)
  partitionCount = partitionCount or 64

  self.chunker = Chunker(gridSize, partitionCount)
end

function PhysicsWorld:getBodyCount()
  return self.chunker.bodyCount
end

function PhysicsWorld:addBody(body)
  body:i_setWorld(self)
  self.chunker:addBody(body)
end

function PhysicsWorld:removeBody(body)
  self.chunker:removeBody(body)
end

function PhysicsWorld:getMaxBodySize()
  return self.chunker.size
end

function PhysicsWorld:draw()
  love.graphics.setColor(1,1,1)
  for x=-20, 20 do
    for y=-20, 20 do
      local dx = x * self.chunker.chunkSize
      local dy = y * self.chunker.chunkSize
      love.graphics.rectangle(
        "line",
        dx, dy,
        self.chunker.chunkSize, self.chunker.chunkSize)
    end
  end

  for body, _ in pairs(self.chunker.bodyMeta) do
    love.graphics.setColor(body:getColor())
    love.graphics.polygon("fill", body:getVerticesInWorld())
  end
  love.graphics.setColor(1, 1, 1)
end

return PhysicsWorld
