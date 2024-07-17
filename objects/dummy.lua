local TiledMap = require("tiled.map")
local Sprite = require("sprite")
local core = require("core")
local shadow = require("shadow")
local object = require("object")

local Dummy = object()

local flash = love.graphics.newShader("vfx/flash.frag")

function Dummy:init(x, y)
  self.sprite = Sprite("assets/dummy.ase")
  self.sprite:alignedOffset("center", "bottom")

  self.x = x
  self.y = y

  self.iframes = 0

  self.recentDamage = 0

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
  self.iframes = 0.1
end

function Dummy:update(dt)
  self.zIndex = self.y
  self.iframes = math.max(self.iframes - dt, 0)
  shadow.queueDraw(self.sprite, self.x, self.y, self.scalex, 1)
end

function Dummy:draw()
  love.graphics.setColor(1, 1, 1)

  local scaley = 1 + self.iframes * 2
  local scalex = 1 - (scaley - 1)

  flash:send("amount", math.ceil(self.iframes))
  love.graphics.setShader(flash)
  self.sprite:draw(self.x, self.y, 0, scalex, scaley)
  love.graphics.setShader()
end

TiledMap.s_addSpawner("Dummy", function(world, data)
  world:add(Dummy(data.x, data.y))
end)
