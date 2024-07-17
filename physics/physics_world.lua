local class = require("class")
local vec = require("vec")
local Chunker = require("physics.chunker")
local Body = require("physics.body")

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

local function rcTestAxis(axisx, axisy, startx, starty, endx, endy, body)
  local rcProjMin = vec.dot(axisx, axisy, startx, starty)
  local rcProjMax = vec.dot(axisx, axisy, endx, endy)
  if rcProjMin > rcProjMax then
    rcProjMin, rcProjMax = rcProjMax, rcProjMin
  end

  local proj= Body.s_projectOntoAxis(body, axisx, axisy)
  if rcProjMax > proj.min and proj.max > rcProjMin then
    return true
  end
  return false
end

function PhysicsWorld:raycast(startx, starty, endx, endy)
  local vecx, vecy = endx - startx, endy - starty

  local dirx, diry = vec.normalize(vecx, vecy)

  -- Use DDA to find all the chunks
  local steps = math.ceil(
    math.max(math.abs(vecx),
    math.abs(vecy)) / self.chunker.chunkSize) + 1

  local axis1x = -diry
  local axis1y = dirx

  local axis2x = dirx
  local axis2y = diry

  local testedChunks = {}

  for i=0, steps-1 do
    local percent = i/steps
    local chunkx, chunky = self.chunker:getChunkCoordsFor(startx + vecx * percent, starty + vecy * percent)
    local neighborChunks = self.chunker:getNeighborChunksAroundPos(chunkx, chunky)

    for _, chunk in ipairs(neighborChunks) do
      if not testedChunks[chunk] then
        testedChunks[chunk] = {}
        for _, body in ipairs(chunk) do
          local allBodyTestPassed = true
          for j=1, #body.vertices, 2 do
            -- Find axis to test
            local p1x = body.vertices[j] + body.anchor.x
            local p1y = body.vertices[j+1] + body.anchor.y

            local p2x, p2y

            if j + 2 > #body.vertices then
              p2x = body.vertices[1] + body.anchor.x
              p2y = body.vertices[2] + body.anchor.y
            else
              p2x = body.vertices[j+2] + body.anchor.x
              p2y = body.vertices[j+3] + body.anchor.y
            end

            -- Axis is just the normal of an edge
            local axisx = -(p1y - p2y)
            local axisy = p1x - p2x
            axisx, axisy = vec.normalize(axisx, axisy)

            if not rcTestAxis(axisx, axisy, startx, starty, endx, endy, body) then
              allBodyTestPassed = false
              break
            end
          end

          if rcTestAxis(axis1x, axis1y, startx, starty, endx, endy, body)
            and rcTestAxis(axis2x, axis2y, startx, starty, endx, endy, body)
            and allBodyTestPassed then
            return body
          end
        end
      end
    end
  end

  return nil
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
