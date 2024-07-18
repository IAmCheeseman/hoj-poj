local Sprite = require("sprite")
local VecAnimPicker = require("animpicker")
local TiledMap = require("tiled.map")
local Gun = require("objects.gun")
local Health = require("health")
local shadow = require("shadow")
local core = require("core")
local object = require("object")
local StateMachine = require("state_machine")

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

  self.defaultState = {
    update = self.defaultUpdate,
  }

  self.attackState = {
    enter = self.attackEnter,
    update = self.attackUpdate,
  }

  self.sm = StateMachine(self, self.defaultState)

  self.attackTimer = 0

  self.scalex = 1

  self.faceDirX = 0
  self.faceDirY = 0

  self.speed = 75
  self.accel = 10
  self.frict = 15

  self.health = Health(self, 20, self.sprite)
  self.health.died:connect(core.world, self.onDied, self)
  self:register(self.health)

  self.body = core.ResolverBody(self, core.physics.diamond(0, -4, 10, 8), {
    mask = {"env"},
  })
  core.physics.world:addBody(self.body)

  self.hurtbox = core.SensorBody(self, core.physics.diamond(0, -3, 8, 6), {
    layers = {"player"},
    groups = {"hurtbox", "player"},
  })
  core.physics.world:addBody(self.hurtbox)
end

function Player:added(world)
  self.gun = Gun(self, 0, -5)
  world:add(self.gun)

  self.gun.fired:connect(core.world, self.onGunFire, self)
end

function Player:removed(world)
  core.physics.world:removeBody(self.body)
  core.physics.world:removeBody(self.hurtbox)

  core.world:remove(self.gun)
end

function Player:onDied()
  core.world:remove(self)
end

function Player:update(dt)
  self.sm:call("update", dt)

  core.mainViewport:setCamPos(math.floor(self.x), math.floor(self.y))

  self.zIndex = self.y
  shadow.queueDraw(self.sprite, self.x, self.y, self.scalex, 1)
end

function Player:onGunFire(bullet)
  self.velx = -math.cos(bullet.rot) * bullet.speed / 2
  self.vely = -math.sin(bullet.rot) * bullet.speed / 2

  self.attackState.dirx, self.attackState.diry =
    core.vec.normalize(-self.velx, -self.vely)

  self.sm:setState(self.attackState)
end

function Player:defaultUpdate(dt)
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

  local tagDir, sx, _ = self.animPicker:pick(dirx, diry)
  local anim = "walk"
  if core.vec.length(self.velx, self.vely) < 5 then
    anim = "idle"
  end

  self.sprite:setActiveTag(tagDir .. anim, true)
  self.scalex = sx
  local animSpeed =
    1.2 - (core.vec.length(self.velx, self.vely) / self.speed)^2 * 0.5
  self.sprite:animate(animSpeed)

  -- Update gun angle
  local gunx, guny = self.gun.x, self.gun.y
  self.gun.angle = core.vec.angleToPoint(gunx, guny, mx, my)
end

function Player:attackEnter()
  self.attackTimer = 0.5
end

function Player:attackUpdate(dt)
  self.velx = core.math.dtLerp(self.velx, 0, self.frict)
  self.vely = core.math.dtLerp(self.vely, 0, self.frict)

  self.velx, self.vely = self.body:moveAndCollide(self.velx, self.vely)

  local dirx, diry = self.attackState.dirx, self.attackState.diry
  local tagDir, sx, _ = self.animPicker:pick(dirx, diry)

  self.sprite:setActiveTag(tagDir .. "idle", true)
  self.scalex = sx

  self.attackTimer = self.attackTimer - dt
  if self.attackTimer <= 0 then
    self.sm:setState(self.defaultState)
  end
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
