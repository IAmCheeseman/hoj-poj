local class = require("class")

local Chunker = class()

local function hashVector(x, y)
  x = math.abs(x)
  y = math.abs(y)
  return math.ceil(x + y + ((x + 1) / 2)^2)
end

function Chunker:init(size, chunkCount)
  chunkCount = chunkCount or 32

  self.size = size or 64
  self.chunk = {}
  self.bodies = {}

  for _=1, chunkCount do
    table.insert(self.chunk, {})
  end
end

function Chunker:iterateNeighbors(body)
  local chunks = self:getNeighborChunks(body)
  local chunkIndex, chunk = next(chunks)
  local bodyIndex = nil
  return function()
    local nextBody
    bodyIndex, nextBody = next(chunk, bodyIndex)
    if not nextBody then
      chunkIndex, chunk = next(chunks, chunkIndex)
      if not chunk then
        return nil
      end
      bodyIndex, nextBody = next(chunk, bodyIndex)
    end
    return nextBody
  end
end

function Chunker:getNeighborChunks(body)
  local ax, ay = body:getPosition()

  local neighbors = {}
  local added = {}

  local width   = self.size / 2
  local height  = self.size / 2

  for i=0, 3*3-1 do
    local ox = i % 3 - 1
    local oy = math.floor(i / 3) - 1

    local index = self:findChunkFor(ax + ox * width, ay + oy * height)
    if not added[index] then
      table.insert(neighbors, self.chunk[index])
    end
    added[index] = true
  end

  return neighbors
end

function Chunker:getNeighborPoints(body)
  local ax, ay = body:getPosition()

  local points = {}

  local width   = self.size / 2
  local height  = self.size / 2

  for i=0, 3*3-1 do
    local ox = i % 3 - 1
    local oy = math.floor(i / 3) - 1

    local point = {x=ax + ox * width, y=ay + oy * height}
    table.insert(points, point)
  end

  return points
end

function Chunker:findChunkFor(bx, by)
  local x, y = math.floor(bx / self.size), math.floor(by / self.size)
  local hash = hashVector(x, y)
  return math.floor(hash % #self.chunk) + 1
end

function Chunker:updateBody(body)
  local bodyIndex = self.bodies[body]
  local chunk = self:findChunkFor(body:getPosition())
  if chunk == bodyIndex.chunk then
    return
  end

  local removing = self.chunk[bodyIndex.chunk]
  local last = removing[#removing]
  removing[bodyIndex.index] = last
  removing[#removing] = nil

  if self.bodies[last] then
    self.bodies[last].index = bodyIndex.index
  end

  table.insert(self.chunk[chunk], body)
  bodyIndex.chunk = chunk
  bodyIndex.index = #self.chunk[chunk]
end

function Chunker:getBodyChunk(body)
  return self.bodies[body].chunk
end

function Chunker:addBody(body)
  local maxSize = self.size
  if body.w > maxSize or body.h > maxSize then
    error(
      ("Body's size is %dx%d, max is %dx%d"):format(
        body.w, body.h, maxSize, maxSize))
  end
  local c = self:findChunkFor(body:getPosition())
  table.insert(self.chunk[c], body)
  self.bodies[body] = {
    chunk = c,
    index = #self.chunk[c]
  }
end

return Chunker
