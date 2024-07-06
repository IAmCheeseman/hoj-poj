local class = require("class")
local TileLayer = require("tiled.tile_layer")

local InfiniteTileLayer = class()

function InfiniteTileLayer:init(map, data)
  self.map = map
  self.tileLayers = {}

  for _, chunk in ipairs(data.chunks) do
    local mockData = {
      width = chunk.width,
      height = chunk.height,
      offsetx = data.offsetx + chunk.x * map.tileWidth,
      offsety = data.offsety + chunk.y * map.tileHeight,
      parallaxx = data.parallaxx,
      parallaxy = data.parallaxy,
      data = chunk.data,
    }

    table.insert(self.tileLayers, TileLayer(map, mockData))
  end
end

function InfiniteTileLayer:draw()
  -- TODO: Only draw chunks on screen
  for _, tileLayer in ipairs(self.tileLayers) do
    tileLayer:draw()
  end
end

return InfiniteTileLayer
