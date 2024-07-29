local class = require("class")
local Body = require("physics.body")

local SensorBody = class(Body)

function SensorBody:init(anchor, shape, options)
  self:base("init", "sensor", anchor, shape, options)
end

function SensorBody:getFirstCollider()
  local neighborChunks = self.world.chunker:getNeighborChunks(self)

  for _, chunk in ipairs(neighborChunks) do
    for _, other in ipairs(chunk) do
      if self:canCollideWith(other) and Body.s_sat(self, other).overlaps then
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
      if other ~= self
      and self:canCollideWith(other)
      and Body.s_sat(self, other).overlaps then
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
