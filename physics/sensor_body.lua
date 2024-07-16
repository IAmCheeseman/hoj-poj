local class = require("class")
local Body = require("physics.body")

local SensorBody = class(Body)

function SensorBody:init(anchor, w, h, options)
  self:base("init", "sensor", anchor, w, h, options)
end

function SensorBody:getFirstCollider()
  local neighborChunks = self.world.chunker:getNeighborChunks(self)

  for _, chunk in ipairs(neighborChunks) do
    for _, other in ipairs(chunk) do
      local isColliding = Body.s_sat(self, other).overlaps
      if self:canCollideWith(other) and isColliding then
        return other
      end
    end
  end

  return nil
end

function SensorBody:isColliding()
  return self:getFirstCollider() ~= nil
end

function SensorBody:getAllColliders()
  local neighborChunks = self.world.chunker:getNeighborChunks(self)

  local neighbors = {}

  for _, chunk in ipairs(neighborChunks) do
    for _, other in ipairs(chunk) do
      local isColliding = Body.s_sat(self, other).overlaps
      if self:canCollideWith(other) and isColliding then
        table.insert(neighbors, other)
      end
    end
  end

  return neighbors
end

function SensorBody:getColor()
  return 1, 0, 0, 0.5
end

return SensorBody
