local class = require("class")

local TileLayer = class()

function TileLayer:init(map, data)
  self.map = map

  self.width = data.width
  self.height = data.height

  self.offsetx = data.offsetx
  self.offsety = data.offsety

  self.parallaxx = data.parallaxx
  self.parallaxy = data.parallaxy

  self.zIndex = data.properties.zIndex or 0

  self.spriteBatches = {}
  self.usedBatches = {}

  for _, tileset in ipairs(map.tilesets) do
    self.spriteBatches[tileset] = tileset:makeSpriteBatch()
  end

  self.data = data.data

  self.drawFunc = love.graphics.draw

  self:regenerateBatches()
end

function TileLayer:regenerateBatches()
  for _, batch in pairs(self.spriteBatches) do
    batch:clear()
  end
  self.usedBatches = {}

  local tileWidth = self.map.tileWidth
  local tileHeight = self.map.tileHeight
  for i, tile in ipairs(self.data) do
    if tile ~= 0 then
      local x = (i - 1) % self.width
      local y = math.floor((i - 1) / self.height)

      local tileset = self.map.globalIds[tile]
      local batch = self.spriteBatches[tileset]
      local quad = tileset:getQuad(tile)

      batch:add(quad, x * tileWidth, y * tileHeight)

      self.usedBatches[batch] = true
    end
  end
end

function TileLayer:draw()
  love.graphics.setColor(1, 1, 1)
  for batch, _ in pairs(self.usedBatches) do
    self.drawFunc(batch, self.offsetx, self.offsety)
  end
end

return TileLayer
