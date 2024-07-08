local class = require("class")
local TileLayer = require("tiled.tile_layer")

local InfiniteTileLayer = class()

function InfiniteTileLayer:init(map, data)
  self.map = map
  self.tileLayers = {}

  self.zIndex = data.properties.zIndex or 0

  self.drawFunc = love.graphics.draw

  for _, chunk in ipairs(data.chunks) do
    local mockData = {
      width = chunk.width,
      height = chunk.height,
      offsetx = data.offsetx + chunk.x * map.tileWidth,
      offsety = data.offsety + chunk.y * map.tileHeight,
      parallaxx = data.parallaxx,
      parallaxy = data.parallaxy,
      data = chunk.data,
      properties = data.properties,
    }

    table.insert(self.tileLayers, TileLayer(map, mockData))
  end
end

function InfiniteTileLayer:draw()
  -- TODO: Only draw chunks on screen
  for _, tileLayer in ipairs(self.tileLayers) do
    local pxWidth = tileLayer.width * self.map.tileWidth
    local pxHeight = tileLayer.height * self.map.tileHeight
    local x = tileLayer.offsetx
    local y = tileLayer.offsety

    if self.map.viewport:hasRect(x, y, pxWidth, pxHeight) then
      tileLayer.drawFunc = self.drawFunc
      tileLayer:draw()
    end
  end
end

return InfiniteTileLayer
