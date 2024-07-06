local log = require("log")
local class = require("class")

local ImageLayer = require("tiled.image_layer")
local TileLayer = require("tiled.tile_layer")
local Tileset = require("tiled.tileset")

local TiledMap = class()

local function loadLayer(map, dir, data)
  if data.type == "imagelayer" then
    return ImageLayer(map, dir, data)
  elseif data.type == "tilelayer" then
    return TileLayer(map, data)
  elseif data.type == "objectgroup" then
    return nil
  end
end

local function loadTileset(map, dir, data)
  local isSingleImage = data.image ~= nil
  if isSingleImage then
    return Tileset(map, dir, data)
  end

  log.info("Ignored tileset '" .. data.name .. "'.")
  -- Ignore collections of images
  return nil
end

function TiledMap:init(path)
  -- love.filesystem.load allows for loading from save directory.
  local tiledData = love.filesystem.load(path)()

  self.width = tiledData.width
  self.height = tiledData.height
  self.tileWidth = tiledData.tilewidth
  self.tileHeight = tiledData.tileheight

  self.pxWidth = self.width * self.tileWidth
  self.pxHeight = self.height * self.tileHeight

  self.globalIds = {}
  self.tilesets = {}
  self.layers = {}

  local dir = path:gsub([[%/[^/]-%..+$]], "")

  for _, data in ipairs(tiledData.tilesets) do
    table.insert(self.tilesets, loadTileset(self, dir, data))
  end

  for _, data in ipairs(tiledData.layers) do
    table.insert(self.layers, loadLayer(self, dir, data))
  end

  log.info("Loaded Tiled map '" .. path .. "'.")
end

function TiledMap:draw()
  for _, layer in ipairs(self.layers) do
    if layer.draw then
      layer:draw()
    end
  end
end

return TiledMap
