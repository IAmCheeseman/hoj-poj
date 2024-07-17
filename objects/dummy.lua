local TiledMap = require("tiled.map")
local Sprite = require("sprite")
local core = require("core")
local shadow = require("shadow")
local object = require("object")

local Dummy = object()

function Dummy:init(x, y)
  self.sprite = Sprite("assets/dummy.ase")
  self.sprite:alignedOffset("center", "bottom")

  self.x = x
  self.y = y

  self.velx = 0
  self.vely = 0

  self.recentDamage = 0

  self.body = core.ResolverBody(self, core.physics.rect(-6, -5, 11, 5), {
    layers = {"env"},
  })
  core.physics.world:addBody(self.body)

  self.hitbox = core.SensorBody(self, core.physics.rect(-6, -15, 11, 15), {
    layers = {"enemy"},
  })
  core.physics.world:addBody(self.hitbox)
end

function Dummy:removed()
  core.physics.world:removeBody(self.body)
  core.physics.world:removeBody(self.hitbox)
end

function Dummy:takeDamage(amount, kbDirX, kbDirY)
  self.recentDamage = amount

  self.velx = self.velx + kbDirX
  self.vely = self.vely + kbDirY
end

function Dummy:update(dt)
  self.velx = core.math.dtLerp(self.velx, 0, 15)
  self.vely = core.math.dtLerp(self.vely, 0, 15)

  self.velx, self.vely = self.body:moveAndCollide(self.velx, self.vely)

  shadow.queueDraw(self.sprite, self.x, self.y, self.scalex, 1)
end

function Dummy:draw()
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y)

  love.graphics.print(self.recentDamage, self.x, self.y)
end

TiledMap.s_addSpawner("Dummy", function(world, data)
  world:add(Dummy(data.x, data.y))
end)
