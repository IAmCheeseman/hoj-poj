local class = require("class")
local vec = require("vec")
local Chunker = require("physics.chunker")
local Body = require("physics.body")
local stats = require("physics.stats")

local PhysicsWorld = class()

function PhysicsWorld:init(world, gridSize, partitionCount)
  gridSize = gridSize or (128 * 2)
  partitionCount = partitionCount or 64

  self.world = world
  self.anchors = {}
  self.chunker = Chunker(gridSize, partitionCount)
end

function PhysicsWorld:getBodyCount()
  return self.chunker.bodyCount
end

function PhysicsWorld:addBody(body)
  body:i_setWorld(self)

  local anchor = body.anchor
  if not self.anchors[anchor] then
    self.anchors[anchor] = {}
  end
  table.insert(self.anchors[anchor], body)

  self.chunker:addBody(body)
end

function PhysicsWorld:removeBody(body)
  self.chunker:removeBody(body)

  local anchor = body.anchor
  local bodies = self.anchors[anchor]
  if not bodies then
    return
  end

  local index = 0
  for i, b in ipairs(bodies) do
    if b == body then
      index = i
      break
    end
  end

  if index ~= 0 then
    table.remove(bodies, index)
    if #bodies == 0 then
      self.anchors[anchor] = nil
    end
  end
end

function PhysicsWorld:updateAnchorBodies(anchor)
  local bodies = self.anchors[anchor]
  if not bodies then
    return
  end

  for _, body in ipairs(bodies) do
    self.chunker:updateBody(body)
  end
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
  stats.raycasts = stats.raycasts + 1

  local vecx, vecy = endx - startx, endy - starty

  local dirx, diry = vec.normalize(vecx, vecy)

  -- Use DDA to find all the chunks
  local steps = math.ceil(
    math.max(math.abs(vecx),
    math.abs(vecy)) / self.chunker.chunkSize) + 1

  local rcAxisPerpX = -diry
  local rcAxisPerpY = dirx

  local rcAxisParX = dirx
  local rcAxisParY = diry

  local testedChunks = {}

  for i=0, steps-1 do
    local percent = i/steps
    local chunkx, chunky = self.chunker:getChunkCoordsFor(
      startx + vecx * percent, starty + vecy * percent)
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

          if rcTestAxis(rcAxisPerpX, rcAxisPerpY, startx, starty, endx, endy, body)
            and rcTestAxis(rcAxisParX, rcAxisParY, startx, starty, endx, endy, body)
            and allBodyTestPassed then
            return body
          end
        end
      end
    end
  end

  return nil
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
    love.graphics.polygon("line", body:getVerticesInWorld())
    love.graphics.print(self.chunker.bodyMeta[body].chunk)
  end
  love.graphics.setColor(1, 1, 1)
end

function PhysicsWorld:update()
  stats.collisionChecks = 0
  stats.resolutions = 0
  stats.raycasts = 0
end

return PhysicsWorld
