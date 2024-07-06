local log = require("log")
local class = require("class")

local Tileset = class()

function Tileset:init(map, dir, data)
  local path, matchCount = data.image:gsub("^%.%.%/", "")
  path = "/" .. path
  if matchCount ~= 0 then
    dir = dir:gsub("%/[^%/]-$", "")
  end
  path = dir .. path

  self.image = love.graphics.newImage(path)
  self.tileWidth = data.tilewidth
  self.tileHeight = data.tileheight
  self.firstGid = data.firstgid - 1

  self.quads = {}

  local xTiles = math.floor(data.imagewidth / data.tilewidth)
  local yTiles = math.floor(data.imageheight / data.tileheight)
  for y=0, yTiles-1 do
    for x=0, xTiles-1 do
      local pixelx, pixely = x * data.tilewidth, y * data.tileheight
      local quad = love.graphics.newQuad(
          pixelx, pixely,
          data.tilewidth, data.tileheight,
          data.imagewidth, data.imageheight)
      table.insert(self.quads, quad)
      table.insert(map.globalIds, self)
    end
  end

  log.info("Loaded tileset '" .. data.name .. "'.")
end

function Tileset:getQuad(gid)
  return self.quads[gid - self.firstGid]
end

function Tileset:makeSpriteBatch()
  return love.graphics.newSpriteBatch(self.image)
end

return Tileset
