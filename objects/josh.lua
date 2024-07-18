local TiledMap = require("tiled.map")
local Sprite = require("sprite")
local Health = require("health")
local StateMachine = require("state_machine")
local VecAnimPicker = require("animpicker")
local core = require("core")
local shadow = require("shadow")
local object = require("object")

local Bullet = require("objects.bullet")

local Josh = object()

function Josh:init(x, y)
  self.sprite = Sprite("assets/josh.ase")
  self.sprite:alignedOffset("center", "bottom")

  self.x = x
  self.y = y

  self.velx = 0
  self.vely = 0

  self.speed = 60
  self.accel = 7
  self.frict = 10

  self.scalex = 1

  self.spitRange = 16 * 4

  self.health = Health(self, 20, self.sprite)
  self:register(self.health)

  self.health.damaged:connect(core.world, self.onDamaged, self)
  self.health.died:connect(core.world, self.onDied, self)

  self.animPicker = VecAnimPicker {
    {"down",      0,  1, { 1,  1}},
    {"up",        0, -1, { 1,  1}},
    {"downside",  1,  1, { 1,  1}},
    {"upside",    1, -1, { 1,  1}},
    {"downside", -1,  1, {-1,  1}},
    {"upside",   -1, -1, {-1,  1}},
  }

  self.idleState = {
    update = self.idleUpdate,
  }

  self.pursueState = {
    update = self.pursueUpdate,
  }

  self.fleeState = {
    enter = self.fleeEnter,
    update = self.fleeUpdate,
    timer = 0,
  }

  self.sm = StateMachine(self, self.idleState)

  self.body = core.ResolverBody(self, core.physics.rect(-5, -4, 10, 4), {
    mask = {"env"},
  })
  core.physics.world:addBody(self.body)

  self.detection = core.SensorBody(self, core.physics.circle(16 * 7, 8), {
    mask = {"player"},
  })
  core.physics.world:addBody(self.detection)

  self.hurtbox = core.SensorBody(self, core.physics.rect(-5, -12, 10, 12), {
    layers = {"enemy"},
    groups = {"hurtbox"},
  })
  core.physics.world:addBody(self.hurtbox)
end

function Josh:removed()
  core.physics.world:removeBody(self.body)
  core.physics.world:removeBody(self.detection)
  core.physics.world:removeBody(self.hurtbox)
end

function Josh:onDamaged(attacker)
  if attacker then
    self.target = attacker
    self.sm:setState(self.pursueState)
  end
end

function Josh:onDied()
  core.world:remove(self)
end

function Josh:update(dt)
  self.sm:call("update", dt)

  self.zIndex = self.y
  shadow.queueDraw(self.sprite, self.x, self.y, self.scalex, 1)
end

function Josh:pursueUpdate()
  local dirx, diry = core.vec.direction(
    self.x, self.y, self.target.x, self.target.y)

  local delta = self.accel
  local currentDirX, currentDirY = core.vec.normalize(self.velx, self.vely)
  if core.vec.dot(dirx, diry, currentDirX, currentDirY) > 0.5 then
    delta = self.frict
  end

  self.velx = core.math.dtLerp(self.velx, dirx * self.speed, delta)
  self.vely = core.math.dtLerp(self.vely, diry * self.speed, delta)

  self.velx, self.vely = self.body:moveAndCollide(self.velx, self.vely)

  local tag, scalex, _ = self.animPicker:pick(dirx, diry)
  self.scalex = scalex
  self.sprite:setActiveTag(tag, true)
  self.sprite:animate()

  local dist = core.vec.distance(self.x, self.y, self.target.x, self.target.y)
  if dist < self.spitRange then
    self.sm:setState(self.fleeState)
  end
end

function Josh:fleeEnter()
  -- Spit here
  local rot = core.vec.angleToPoint(self.x, self.y, self.target.x, self.target.y)
  local speed = 150

  local offset = 16

  local x, y =
    self.x + math.cos(rot) * offset,
    self.y + math.sin(rot) * offset

  local bullet = Bullet(self.anchor, x, y, rot, speed)
  bullet.damage = 6
  core.world:add(bullet)

  self.fleeState.timer = 1
end

function Josh:fleeUpdate(dt)
  local dirx, diry = core.vec.direction(
    self.x, self.y, self.target.x, self.target.y)
  dirx, diry = -dirx, -diry

  local delta = self.accel
  local currentDirX, currentDirY = core.vec.normalize(self.velx, self.vely)
  if core.vec.dot(dirx, diry, currentDirX, currentDirY) > 0.5 then
    delta = self.frict
  end

  self.velx = core.math.dtLerp(self.velx, dirx * self.speed, delta)
  self.vely = core.math.dtLerp(self.vely, diry * self.speed, delta)

  self.velx, self.vely = self.body:moveAndCollide(self.velx, self.vely)

  self.fleeState.timer = self.fleeState.timer - dt
  if self.fleeState.timer < 0 then
    self.sm:setState(self.pursueState)
  end
end

function Josh:idleUpdate()
  self.velx = core.math.dtLerp(self.velx, 0, self.frict)
  self.vely = core.math.dtLerp(self.vely, 0, self.frict)

  self.velx, self.vely = self.body:moveAndCollide(self.velx, self.vely)

  local dirx, diry =
    math.cos(core.getRuntime() * 5),
    math.sin(core.getRuntime() * 5)
  local tag, scalex, _ = self.animPicker:pick(dirx, diry)

  self.scalex = scalex
  self.sprite:setActiveTag(tag, true)
  self.sprite:animate()

  local colliders = self.detection:getAllColliders()
  for _, collider in ipairs(colliders) do
    if collider:isInGroup("player") then
      self.target = collider.anchor
      self.sm:setState(self.pursueState)
    end
  end
end

function Josh:draw()
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y, 0, self.scalex, 1)
end

TiledMap.s_addSpawner("Josh", function(world, data)
  world:add(Josh(data.x, data.y))
end)

return Josh
