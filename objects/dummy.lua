local TiledMap = require("tiled.map")
local Sprite = require("sprite")
local Health = require("health")
local core = require("core")
local shadow = require("shadow")
local object = require("object")

local Dummy = object()

function Dummy:init(x, y)
  self.sprite = Sprite("assets/dummy.ase")
  self.sprite:alignedOffset("center", "bottom")

  self.x = x
  self.y = y

  self.health = Health(self, math.huge)
  self:register(self.health)

  self.hitbox = core.SensorBody(self, core.physics.rect(-6, -15, 11, 15), {
    layers = {"enemy"},
  })
  core.physics.world:addBody(self.hitbox)
end

function Dummy:removed()
  core.physics.world:removeBody(self.body)
  core.physics.world:removeBody(self.hitbox)
end

function Dummy:update()
  self.zIndex = self.y
  shadow.queueDraw(self.sprite, self.x, self.y, self.scalex, 1)
end

function Dummy:draw()
  self.health:drawSprite(self.sprite, self.x, self.y)
end

TiledMap.s_addSpawner("Dummy", function(world, data)
  world:add(Dummy(data.x, data.y))
end)
