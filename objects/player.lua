local class = require("class")
local mathf = require("mathf")
local vec = require("vec")
local input = require("input")
local physics = require("physics")
local Sprite = require("sprite")
local VecAnimPicker = require("animpicker")
local TiledMap = require("tiled.map")

local Player = class()

function Player:init()
  self.tex = Sprite("assets/player/player.ase")
  self.tex:alignedOffset("center", "bottom")

  self.animPicker = VecAnimPicker {
    {"d",   0,  1, { 1,  1}},
    {"u",   0, -1, { 1,  1}},
    {"ds",  1,  1, { 1,  1}},
    {"us",  1, -1, { 1,  1}},
    {"ds", -1,  1, {-1,  1}},
    {"us", -1, -1, {-1,  1}},
  }

  self.scalex = 1

  self.x = 0
  self.y = 0

  self.faceDirX = 0
  self.faceDirY = 0

  self.speed = 75
  self.accel = 10
  self.frict = 15

  self.body = physics.Body(
    self, "dynamic",
    physics.diamondShape(0, -8, 7, 13))
  self.body:setFixedRotation(true)

  self.body:setGroup(playerGroup)
  self.body:setCategory(playerCategory, true)
  self.body:setMask(envCategory, true)
end

function Player:update(dt)
  local vx, vy = self.body:getVelocity()

  local ix, iy = 0, 0
  if input.isActionDown("walk_up")    then iy = iy - 1 end
  if input.isActionDown("walk_left")  then ix = ix - 1 end
  if input.isActionDown("walk_down")  then iy = iy + 1 end
  if input.isActionDown("walk_right") then ix = ix + 1 end

  ix, iy = vec.normalize(ix, iy)

  local ld = self.accel
  local cdx, cdy = vec.normalize(vx, vy)
  if vec.dot(cdx, cdy, ix, iy) < 0.5 then
    ld = self.frict
  end

  vx = mathf.dtLerp(vx, ix * self.speed, ld)
  vy = mathf.dtLerp(vy, iy * self.speed, ld)

  self.body:setVelocity(vx, vy)

  self.x, self.y = self.body:getPosition()

  -- Prevents the sprite from facing down when standing still
  if vx ~= 0 then
    self.faceDirX = vx
  end
  if vy ~= 0 then
    self.faceDirY = vy
  end

  local tagDir, sx, _ = self.animPicker:pick(
    vec.normalize(self.faceDirX, self.faceDirY))
  local anim = "walk"
  if vec.length(vx, vy) < 5 then
    anim = "idle"
  end

  self.tex:setActiveTag(tagDir .. anim)
  self.scalex = sx
  local animSpeed = 1 - (vec.length(vx, vy) / self.speed)^2 * 0.5
  self.tex:animate(animSpeed)

  mainViewport:setCamPos(self.x, self.y)
end

function Player:draw()
  love.graphics.setColor(1, 1, 1)
  self.tex:draw(self.x, self.y, 0, self.scalex, 1)
  love.graphics.setColor(0, 0, 0, 0.33)
  self.tex:draw(self.x, self.y, 0, 1, -0.5, -0.5, 0)
end

TiledMap.s_addSpawner("Player", function(world, object)
  local player = Player()
  player.body:setPosition(object.x, object.y)
  world:add(player)
end)

return Player
