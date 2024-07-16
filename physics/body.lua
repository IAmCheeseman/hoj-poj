local class = require("class")

local Body = class()

function Body.s_aabbX(x1, w1, x2, w2)
  return x1 + w1 > x2
     and x2 + w2 > x1
end

function Body.s_aabbY(y1, h1, y2, h2)
  return y1 + h1 > y2
     and y2 + h2 > y1
end

function Body.s_aabb(x1, y1, w1, h1, x2, y2, w2, h2)
  return Body.s_aabbX(x1, w1, x2, w2) and Body.s_aabbY(y1, h1, y2, h2)
end

local function convertArrToSet(arr)
  local set = {}
  for _, layer in ipairs(arr) do
    set[layer] = true
  end
  return set
end

local function verifyAnchor(anchor, errIndex)
  errIndex = errIndex + 1

  local requiredProperties = {
    x = "number",
    y = "number",
  }

  for k, requiredType in pairs(requiredProperties) do
    local keyType = type(anchor[k])
    if keyType ~= requiredType then
      error(
        ("Anchor requires '%s' to be %s, got %s."):format(
          k, requiredType, keyType),
        errIndex)
    end
  end
end

function Body:init(type, anchor, w, h, options)
  verifyAnchor(anchor, 1)

  self.type = type
  self.anchor = anchor
  self.w = w
  self.h = h
  self.offsetx = options.offsetx or 0
  self.offsety = options.offsety or 0

  local layers = options.layers or {}
  local mask = options.mask or {}

  self.layers = convertArrToSet(layers)
  self.mask = convertArrToSet(mask)

  self.isOnFloor = false
  self.isOnCeiling = false
  self.isOnWall = false
  self.isOnLeftWall = false
  self.isOnRightWall = false
end

function Body:canCollideWith(other)
  for mask, _ in pairs(self.mask) do
    if other.layers[mask] then
      return true
    end
  end
  return false
end

function Body:getPosition()
  return self.anchor.x + self.offsetx, self.anchor.y + self.offsety
end

function Body:i_setWorld(world)
  self.world = world
end

function Body:drawNeighbors()
  local points = self.world.chunker:getNeighborPoints(self)
  love.graphics.setColor(1, 0, 0)
  for _, point in ipairs(points) do
    love.graphics.circle("fill", point.x, point.y, 3)
  end

  for body in self.world.chunker:iterateNeighbors(self) do
    love.graphics.setColor(body:getColor())
    local x, y = body:getPosition()
    love.graphics.rectangle("fill", x, y, body.w, body.h)
  end
end

-- When bodies are drawn, different types can have different colors.
function Body:getColor()
  return 1, 1, 1, 0.5
end

return Body
