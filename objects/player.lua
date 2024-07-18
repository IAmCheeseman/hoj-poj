local Sprite = require("sprite")
local VecAnimPicker = require("animpicker")
local TiledMap = require("tiled.map")
local Gun = require("objects.gun")
local Health = require("health")
local shadow = require("shadow")
local core = require("core")
local object = require("object")

local Player = object()

function Player:init()
  self.sprite = Sprite("assets/player/player.ase")
  self.sprite:alignedOffset("center", "bottom")
  self.sprite:setLayerVisible("hands", false)

  self.velx = 0
  self.vely = 0

  self.animPicker = VecAnimPicker {
    {"d",   0,  1, { 1,  1}},
    {"u",   0, -1, { 1,  1}},
    {"ds",  1,  1, { 1,  1}},
    {"us",  1, -1, { 1,  1}},
    {"ds", -1,  1, {-1,  1}},
    {"us", -1, -1, {-1,  1}},
  }

  self.scalex = 1

  self.faceDirX = 0
  self.faceDirY = 0

  self.speed = 75
  self.accel = 10
  self.frict = 15

  self.health = Health(self, 20, self.sprite)
  self:register(self.health)

  self.body = core.ResolverBody(self, core.physics.diamond(0, -4, 10, 8), {
    layers = {"player"},
    mask = {"env"},
  })
  core.physics.world:addBody(self.body)

  self.hitbox = core.SensorBody(self, core.physics.diamond(0, -3, 8, 6), {
    layers = {"player"},
  })
  core.physics.world:addBody(self.hitbox)
end

function Player:added(world)
  self.gun = Gun(self, 0, -5)
  world:add(self.gun)
end

function Player:removed(world)
  core.physics.world:removeBody(self.body)
  core.physics.world:removeBody(self.hitbox)
end

function Player:update(dt)
  local ix, iy = 0, 0
  if core.input.isActionDown("walk_up")    then iy = iy - 1 end
  if core.input.isActionDown("walk_left")  then ix = ix - 1 end
  if core.input.isActionDown("walk_down")  then iy = iy + 1 end
  if core.input.isActionDown("walk_right") then ix = ix + 1 end

  ix, iy = core.vec.normalize(ix, iy)

  local ld = self.accel
  local cdx, cdy = core.vec.normalize(self.velx, self.vely)
  if core.vec.dot(cdx, cdy, ix, iy) < 0.5 then
    ld = self.frict
  end

  self.velx = core.math.dtLerp(self.velx, ix * self.speed, ld)
  self.vely = core.math.dtLerp(self.vely, iy * self.speed, ld)

  self.velx, self.vely = self.body:moveAndCollide(self.velx, self.vely)

  -- Prevents the sprite from facing down when standing still
  if self.velx ~= 0 then
    self.faceDirX = self.velx
  end
  if self.vely ~= 0 then
    self.faceDirY = self.vely
  end

  local mx, my = core.mainViewport:mousePos()
  local dirx, diry = core.vec.direction(self.x, self.y, mx, my)

  local tagDir, sx, _ = self.animPicker:pick(
    dirx, diry)
    -- vec.normalize(self.faceDirX, self.faceDirY))
  local anim = "walk"
  if core.vec.length(self.velx, self.vely) < 5 then
    anim = "idle"
  end

  self.sprite:setActiveTag(tagDir .. anim, true)
  self.scalex = sx
  local animSpeed =
    1.2 - (core.vec.length(self.velx, self.vely) / self.speed)^2 * 0.5
  self.sprite:animate(animSpeed)

  self.zIndex = self.y

  core.mainViewport:setCamPos(math.floor(self.x), math.floor(self.y))

  -- Update gun angle
  local gunx, guny = self.gun.x, self.gun.y
  self.gun.angle = core.vec.angleToPoint(gunx, guny, mx, my)

  shadow.queueDraw(self.sprite, self.x, self.y, self.scalex, 1)
end

function Player:draw()
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y, 0, self.scalex, 1)
end

TiledMap.s_addSpawner("Player", function(world, data)
  local player = Player()
  player.x = data.x
  player.y = data.y
  world:add(player)
end)

return Player
