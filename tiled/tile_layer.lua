local class = require("class")

local TileLayer = class()

function TileLayer:init(map, data)
  self.map = map

  self.width = data.width
  self.height = data.height

  self.parallaxx = data.parallaxx
  self.parallaxy = data.parallaxy

  self.spriteBatches = {}

  for _, tileset in ipairs(map.tilesets) do
    self.spriteBatches[tileset] = tileset:makeSpriteBatch()
  end

  self.data = data.data

  self:regenerateBatches()
end

function TileLayer:regenerateBatches()
  for _, batch in pairs(self.spriteBatches) do
    batch:clear()
  end

  for i, tile in ipairs(self.data) do
    if tile ~= 0 then
      local x = i % self.width
      local y = math.floor(i / self.height)

      local tileset = self.map.globalIds[tile]
      local batch = self.spriteBatches[tileset]
      local quad = tileset:getQuad(tile)

      batch:add(quad, x * tileset.tileWidth, y * tileset.tileHeight)
    end
  end
end

function TileLayer:draw()
  love.graphics.rectangle("line", 0, 0, self.width * 8, self.height * 8)
  for _, batch in pairs(self.spriteBatches) do
    love.graphics.draw(batch)
  end
end

return TileLayer
