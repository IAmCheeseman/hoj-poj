local Sprite = require("sprite")
local VecAnimPicker = require("animpicker")
local TiledMap = require("tiled.map")
local Health = require("health")
local shadow = require("shadow")
local core = require("core")
local object = require("object")
local StateMachine = require("state_machine")
local Inventory = require("inventory")
local kg = require("ui.kirigami")
local Hud = require("ui.hud")
local uiSetup = require("ui.setup")

local Player = object()

function Player:init()
  core.input.actionTriggered:connect(core.world, self.onActionTriggered, self)
  core.input.mouseWheelMoved:connect(core.world, self.onMouseWheelScrolled, self)

  self.sprite = Sprite("assets/player/player.ase")
  self.sprite:alignedOffset("center", "bottom")

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

  self.sm = StateMachine(self, self.defaultState)

  self.scalex = 1

  self.faceDirX = 0
  self.faceDirY = 0

  self.speed = 75
  self.accel = 10
  self.frict = 15

  self.inventory = Inventory(self)
  self.inventory:addItem("gun")
  self.inventory:refreshCurrentWeapon(core.world)

  self.health = Health(self, 20, self.sprite)
  self.health.died:connect(core.world, self.onDied, self)

  self.hud = Hud(self.inventory, self.health)
  self.hud:makeRoot()
  uiSetup.connectEvents(core.guiViewport, self.hud)

  self:register(self.health, self.inventory)

  self.body = core.ResolverBody(self, core.physics.diamond(0, -4, 10, 8), {
    mask = {"env"},
  })
  core.pWorld:addBody(self.body)

  self.hurtbox = core.SensorBody(self, core.physics.diamond(0, -3, 8, 6), {
    layers = {"player"},
    groups = {"hurtbox", "player"},
  })
  core.pWorld:addBody(self.hurtbox)
end

function Player:removed(world)
  core.pWorld:removeBody(self.body)
  core.pWorld:removeBody(self.hurtbox)

  self.inventory:removeCurrentWeapon(core.world)
end

function Player:onDied()
  core.world:remove(self)
end

function Player:update(dt)
  self.sm:call("update", dt)

  core.mainViewport:setCamPos(math.floor(self.x), math.floor(self.y))

  self.sprite:setLayerVisible("hands", not self.inventory:getCurrentWeapon())

  self.zIndex = self.y
  shadow.queueDraw(self.sprite, self.x, self.y, self.scalex, 1)
end

function Player:onItemUse(itemId, ...)
  local args = {...}

  if itemId == "gun" then
    local bullet = args[1]

    self.velx = -math.cos(bullet.rot) * bullet.speed / 2
    self.vely = -math.sin(bullet.rot) * bullet.speed / 2

    self.attackState.dirx, self.attackState.diry =
    core.vec.normalize(-self.velx, -self.vely)

    self.sm:setState(self.attackState)
  end
end

function Player:onActionTriggered(action)
  if action == "switch_weapon" then
    self.inventory:switchWeapon(core.world)
  end
end

function Player:onMouseWheelScrolled(_, _)
  self.inventory:switchWeapon(core.world)
end

function Player:defaultUpdate()
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

  local dirx, diry
  local mx, my = core.mainViewport:mousePos()
  if self.inventory:getCurrentWeapon() then
    dirx, diry = core.vec.direction(self.x, self.y, mx, my)
  else
    dirx, diry = core.vec.normalize(self.velx, self.vely)
  end

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
  local heldItem = self.inventory:getCurrentWeapon()
  if heldItem then
    local itemx, itemy = heldItem.x, heldItem.y
    heldItem.angle = core.vec.angleToPoint(itemx, itemy, mx, my)
    heldItem.offsety = -5
    if core.input.isActionDown("use_item") then
      self.inventory:useItem()
    end
  end
end

function Player:draw()
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y, 0, self.scalex, 1)
end

function Player:gui()
  local width, height = core.guiViewport:getSize()
  local screen = kg.Region(0, 0, width, height)
  self.hud:render(screen:get())
end

TiledMap.s_addSpawner("Player", function(world, data)
  local player = Player()
  player.x = data.x
  player.y = data.y
  world:add(player)
end)

return Player
