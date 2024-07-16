local Sprite = require("sprite")
local VecAnimPicker = require("animpicker")
local TiledMap = require("tiled.map")
local Gun = require("objects.gun")
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

  self.body = core.ResolverBody(self, 8, 8, {
    offsetx = -4,
    offsety = -8,

    layers = {"player"},
    mask = {"env"},
  })
  core.physics.world:addBody(self.body)
end

function Player:added(world)
  self.gun = Gun(self, 0, -5)
  world:add(self.gun)
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

  self.sprite:setActiveTag(tagDir .. anim)
  self.scalex = sx
  local animSpeed = 1 - (core.vec.length(self.velx, self.vely) / self.speed)^2 * 0.5
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

  -- self.body:drawNeighbors()
end

TiledMap.s_addSpawner("Player", function(world, data)
  local player = Player()
  player.x = data.x
  player.y = data.y
  world:add(player)
end)

return Player
