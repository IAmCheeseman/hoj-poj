local log = require("log")
local class = require("class")

local ImageLayer = require("tiled.image_layer")
local TileLayer = require("tiled.tile_layer")
local InfiniteTileLayer = require("tiled.infinite_tile_layer")
local Tileset = require("tiled.tileset")
local physics = require("physics")

local world
local objectSpawners = {}

local TiledMap = class()

function TiledMap.s_addSpawner(className, spawner)
  objectSpawners[className] = spawner
end

local function createObjects(data)
  for _, object in ipairs(data.objects) do
    local className = object.properties.className
    if className then
      local spawner = objectSpawners[className]
      if spawner then
        spawner(world, object)
      else
        log.error("No spawner named '" .. tostring(className) .. "'")
      end
    end
  end
end

local function createCollisions(data)
  for _, object in ipairs(data.objects) do
    local shape
    if object.shape == "rectangle" then
      shape = love.physics.newRectangleShape(
        object.width / 2, object.height / 2,
        object.width, object.height)
    else
      log.error("Invalid shape '" .. tostring(object.shape) .. "'. Ingoring.")
    end

    if shape then
      local xy = {x=object.x, y=object.y}
      local body = physics.Body(xy, "static", shape)
      body:setCategory(envCategory, true)
      body:setMask(playerCategory, true)
    end
  end
end

local function loadLayer(map, dir, data)
  if data.type == "imagelayer" then
    return ImageLayer(map, dir, data)
  elseif data.type == "tilelayer" then
    if data.chunks then
      return InfiniteTileLayer(map, data)
    else
      return TileLayer(map, data)
    end
  elseif data.type == "objectgroup" then
    if data.properties.isCollision then
      createCollisions(data)
    else
      createObjects(data)
    end
    return nil
  end
end

local function loadTileset(map, dir, data)
  local isSingleImage = data.image ~= nil
  if isSingleImage then
    return Tileset(map, dir, data)
  end

  -- Keep global ids aligned
  for i=1, #data.tiles do
    table.insert(map.globalIds, i)
  end
  log.info("Ignored tileset '" .. data.name .. "'.")
  -- Ignore collections of images
  return nil
end

function TiledMap:init(mapWorld, viewport, path)
  -- love.filesystem.load allows for loading from save directory.
  local tiledData = love.filesystem.load(path)()

  world = mapWorld
  self.viewport = viewport
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
    local layer = loadLayer(self, dir, data)
    if layer then
      table.insert(self.layers, layer)
    end
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
