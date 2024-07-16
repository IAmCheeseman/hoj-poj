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

local function getOffset(offsetx, offsety, w, h)
  offsetx = offsetx or 0
  offsety = offsety or 0

  if type(offsetx) == "string" then
    if offsetx == "left" then
      offsetx = 0
    elseif offsetx == "center" then
      offsetx = -w / 2
    elseif offsetx == "right" then
      offsetx = -w
    else
      error(
        "Invalid value for 'offsetx'. Valid values are 'left', 'center', and 'right'",
        2)
    end
  end

  if type(offsety) == "string" then
    if offsety == "top" then
      offsety = 0
    elseif offsety == "center" then
      offsety = -h / 2
    elseif offsety == "bottom" then
      offsety = -h
    else
      error(
        "Invalid value for 'offsety'. Valid values are 'top', 'center', and 'bottom'",
        2)
    end
  end

  return offsetx, offsety
end

function Body:init(type, anchor, w, h, options)
  verifyAnchor(anchor, 1)

  self.type = type
  self.anchor = anchor
  self.w = w
  self.h = h

  self.offsetx, self.offsety = getOffset(options.offsetx, options.offsety, w, h)

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

function Body:drawNeighbors(radius)
  radius = radius or 3
  local neighborChunks = self.world.chunker:getNeighborChunks(self)

  for _, chunk in ipairs(neighborChunks) do
    for _, body in ipairs(chunk) do
      love.graphics.setColor(body:getColor())
      local x, y = body:getPosition()
      love.graphics.rectangle("fill", x, y, body.w, body.h)
    end
  end
end

-- When bodies are drawn, different types can have different colors.
function Body:getColor()
  return 1, 1, 1, 0.5
end

return Body
