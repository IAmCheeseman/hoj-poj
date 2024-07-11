local object = require("object")
local Sprite = require("sprite")
local TiledMap = require("tiled.map")

local StaticProp = object()

function StaticProp:init(sprite, x, y)
  self.sprite = sprite
  self.x = x
  self.y = y
  self.zIndex = self.y
end

function StaticProp:draw()
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y)
end

local bushSprite = Sprite("assets/env/bush.png")
bushSprite:alignedOffset("left", "bottom")
TiledMap.s_addSpawner("Bush", function(world, obj)
  local prop = StaticProp(bushSprite, obj.x, obj.y)
  world:add(prop)
end)
