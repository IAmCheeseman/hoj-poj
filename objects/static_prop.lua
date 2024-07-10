local class = require("class")
local Sprite = require("sprite")
local TiledMap = require("tiled.map")

local StaticProp = class()

function StaticProp:init(sprite, x, y)
  self.sprite = sprite
  self.x = x
  self.y = y
  self.zIndex = -1
end

function StaticProp:draw()
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y)
end

local bushSprite = Sprite("assets/env/bush.png")
bushSprite:alignedOffset("left", "bottom")
TiledMap.s_addSpawner("Bush", function(world, object)
  local prop = StaticProp(bushSprite, object.x, object.y)
  world:add(prop)
end)
