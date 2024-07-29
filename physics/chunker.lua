local class = require("class")

local Chunker = class()

function Chunker:init(chunkSize, chunkCount)
  chunkCount = chunkCount or 32

  self.chunkSize = chunkSize or 64
  self.bodyCount = 0
  self.chunks = {}
  self.bodyMeta = {}
end

function Chunker:getNeighborChunksAroundPos(chunkx, chunky, chunkRadius)
  chunkRadius = chunkRadius or 3

  local neighbors = {}

  for i=0, chunkRadius^2-1 do
    local x = i % chunkRadius - math.floor(chunkRadius / 2)
    local y = math.floor(i / chunkRadius) - math.floor(chunkRadius / 2)

    local key = self:makeKey(chunkx + x, chunky + y)
    if self.chunks[key] then
      table.insert(neighbors, self.chunks[key])
    end
  end

  return neighbors
end

function Chunker:getNeighborChunks(body, chunkRadius)
  local chunkx, chunky = self:getChunkCoordsFor(body:getPosition())

  return self:getNeighborChunksAroundPos(chunkx, chunky, chunkRadius)
end

function Chunker:makeKey(x, y)
  return tostring(x) .. "," .. tostring(y)
end

function Chunker:getChunkCoordsFor(bodyx, bodyy)
  local x = math.floor(bodyx / self.chunkSize)
  local y = math.floor(bodyy / self.chunkSize)
  return x, y
end

function Chunker:findChunkFor(bodyx, bodyy)
  local x, y = self:getChunkCoordsFor(bodyx, bodyy)
  local key = self:makeKey(x, y)
  if not self.chunks[key] then
    self.chunks[key] = {}
  end
  return key
end

function Chunker:updateBody(body)
  self:removeBodyFromChunk(body)

  -- Find new chunk that it's in, and insert
  local meta = self.bodyMeta[body]

  local newChunkKey = self:findChunkFor(body:getPosition())
  local newChunk = self.chunks[newChunkKey]
  table.insert(newChunk, body)
  meta.chunk = newChunkKey
  meta.index = #newChunk
end

function Chunker:getBodyChunk(body)
  return self.bodyMeta[body].chunk
end

function Chunker:addBody(body)
  local maxSize = self.chunkSize
  local _, _, w, h = body:getAabb()
  if w > maxSize or h > maxSize then
    error(
      ("Body's size is %dx%d, max is %dx%d"):format(
        w, h, maxSize, maxSize))
  end
  self.bodyCount = self.bodyCount + 1
  local key = self:findChunkFor(body:getPosition())
  table.insert(self.chunks[key], body)
  self.bodyMeta[body] = {
    chunk = key,
    index = #self.chunks[key]
  }
end

function Chunker:removeBodyFromChunk(body)
  local meta = self.bodyMeta[body]
  local chunkKey = meta.chunk
  local index = meta.index

  local chunk = self.chunks[chunkKey]

  if #chunk ~= 1 then
    -- Remove from chunk
    local last = chunk[#chunk]
    chunk[index] = last
    chunk[#chunk] = nil

    self.bodyMeta[last].index = index
  else
    -- This chunk is now empty; remove.
    self.chunks[chunkKey] = nil
  end
end

function Chunker:removeBody(body)
  self.bodyCount = self.bodyCount - 1
  self:removeBodyFromChunk(body)
  self.bodyMeta[body] = nil
end

return Chunker
