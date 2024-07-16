local log = require("log")
local class = require("class")
local core = require("core")

local ImageLayer = require("tiled.image_layer")
local TileLayer = require("tiled.tile_layer")
local InfiniteTileLayer = require("tiled.infinite_tile_layer")
local Tileset = require("tiled.tileset")

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
        spawner(core.world, object)
      else
        log.error("No spawner named '" .. tostring(className) .. "'")
      end
    end
  end
end

local function createCollisions(data)
  for _, object in ipairs(data.objects) do
    local w, h
    if object.shape == "rectangle" then
      w, h = object.width, object.height
    else
      log.error(
        "Invalid map collision '" .. tostring(object.shape) .. "'. Ingoring.")
    end

    if w and h then
      local xy = {x=object.x, y=object.y, velx=0, vely=0}
      local body = core.ResolverBody(xy, w, h, {
        layers = {"env"},
      })
      core.physics.world:addBody(body)
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

function TiledMap:init(viewport, path, callbacks)
  -- love.filesystem.load allows for loading from save directory.
  local tiledData = love.filesystem.load(path)()
  callbacks = callbacks or {}

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
    local tileset = loadTileset(self, dir, data)
    table.insert(self.tilesets, tileset)
    if callbacks.tileset then
      callbacks.tileset(tileset, data)
    end
  end

  for _, data in ipairs(tiledData.layers) do
    local layer = loadLayer(self, dir, data)
    if layer then
      core.world:add(layer)
      table.insert(self.layers, layer)

      if callbacks.layer then
        callbacks.layer(layer, data)
      end
    end
  end

  log.info("Loaded Tiled map '" .. path .. "'.")
end

function TiledMap:draw()
  -- for _, layer in ipairs(self.layers) do
  --   if layer.draw then
  --     layer:draw()
  --   end
  -- end
end

return TiledMap
