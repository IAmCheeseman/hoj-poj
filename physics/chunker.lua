local class = require("class")

local Chunker = class()

local function hashVector(x, y)
  x = math.abs(x)
  y = math.abs(y)
  return math.ceil(x + y + ((x + 1) / 2)^2)
end

function Chunker:init(chunkSize, chunkCount)
  chunkCount = chunkCount or 32

  self.chunkSize = chunkSize or 64
  self.chunks = {}
  self.bodyMeta = {}
end

function Chunker:getNeighborChunks(body, chunkRadius)
  chunkRadius = chunkRadius or 3

  local chunkx, chunky = self:getChunkCoordsFor(body:getPosition())

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
  -- Updates the chunk that a body is in
  local meta = self.bodyMeta[body]
  local chunkKey = meta.chunk
  local index = meta.index

  local chunk = self.chunks[chunkKey]

  if #chunk ~= 1 then
    -- Remove from chunk
    local last = chunk[#chunk]
    chunk[index] = last
    chunk[#chunk] = nil
  else
    -- This chunk is now empty; remove.
    self.chunks[chunkKey] = nil
  end

  -- Find new chunk that it's in, and insert
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
  if body.w > maxSize or body.h > maxSize then
    error(
      ("Body's size is %dx%d, max is %dx%d"):format(
        body.w, body.h, maxSize, maxSize))
  end
  local key = self:findChunkFor(body:getPosition())
  table.insert(self.chunks[key], body)
  self.bodyMeta[body] = {
    chunk = key,
    index = #self.chunks[key]
  }
end

return Chunker
