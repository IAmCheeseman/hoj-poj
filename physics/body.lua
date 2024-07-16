local class = require("class")
local vec = require("vec")

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

local function projectOntoAxis(body, axisx, axisy)
  local min = vec.dot(
    axisx, axisy,
    body.vertices[1] + body.anchor.x, body.vertices[2] + body.anchor.y)
  local max = min

  for i=1, #body.vertices, 2 do
    local p = vec.dot(
      axisx, axisy,
      body.vertices[i] + body.anchor.x, body.vertices[i + 1] + body.anchor.y)
    if p < min then
      min = p
    elseif p > max then
      max = p
    end
  end

  return {
    min = min,
    max = max,
    length = max - min
  }
end

local function checkSat(body1, body2, check, result)
  for i=1, #check.vertices, 2 do
    -- Find axis to test
    local p1x = check.vertices[i] + check.anchor.x
    local p1y = check.vertices[i+1] + check.anchor.y

    local p2x, p2y

    if i + 2 > #check.vertices then
      p2x = check.vertices[1] + check.anchor.x
      p2y = check.vertices[2] + check.anchor.y
    else
      p2x = check.vertices[i+2] + check.anchor.x
      p2y = check.vertices[i+3] + check.anchor.y
    end

    -- Axis is just the normal of an edge
    local axisx = -(p1y - p2y)
    local axisy = p1x - p2x
    axisx, axisy = vec.normalize(axisx, axisy)

    -- Project the shapes onto the axis
    local proj1 = projectOntoAxis(body1, axisx, axisy)
    local proj2 = projectOntoAxis(body2, axisx, axisy)
    if proj1.max < proj2.min or proj2.max < proj1.min then
      result.overlaps = false
      return result
    else
      local overlap = math.min(proj1.max - proj2.min, proj2.max - proj1.min)
      if overlap < result.smallestOverlap then
        result.smallestOverlap = overlap
        result.resolvex = axisx * overlap
        result.resolvey = axisy * overlap
      end
    end
  end
  return result
end

function Body.s_sat(body1, body2)
  local result = {
    overlaps = true,
    resolvex = 0,
    resolvey = 0,
    smallestOverlap = math.huge
  }

  checkSat(body1, body2, body1, result)
  if result.overlaps then
    checkSat(body1, body2, body2, result)
  end
  return result
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

function Body:init(type, anchor, vertices, options)
  verifyAnchor(anchor, 0)
  if not love.math.isConvex(vertices) then
    error("Shape must be convex")
  end

  self.type = type
  self.anchor = anchor
  self.vertices = vertices

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

function Body:getVerticesInWorld()
  local worldVert = {}
  for i=1, #self.vertices, 2 do
    table.insert(worldVert, self.vertices[i] + self.anchor.x)
    table.insert(worldVert, self.vertices[i + 1] + self.anchor.y)
  end
  return worldVert
end

function Body:getPosition()
  return self.anchor.x, self.anchor.y
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
