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

  self.scalex = 1

  self.health = Health(self, math.huge, self.sprite)
  self:register(self.health)

  self.health.damaged:connect(core.world, self.onDamaged, self)

  self.hitbox = core.SensorBody(self, core.physics.rect(-6, -15, 11, 15), {
    layers = {"enemy"},
  })
  core.physics.world:addBody(self.hitbox)
end

function Dummy:removed()
  core.physics.world:removeBody(self.body)
  core.physics.world:removeBody(self.hitbox)
end

function Dummy:onDamaged(...)
  self.scalex = -self.scalex
end

function Dummy:update()
  self.zIndex = self.y
  shadow.queueDraw(self.sprite, self.x, self.y, self.scalex, 1)
end

function Dummy:draw()
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y, 0, self.scalex, 1)
end

TiledMap.s_addSpawner("Dummy", function(world, data)
  world:add(Dummy(data.x, data.y))
end)
