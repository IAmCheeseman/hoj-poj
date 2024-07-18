local TiledMap = require("tiled.map")
local Sprite = require("sprite")
local Health = require("health")
local StateMachine = require("state_machine")
local VecAnimPicker = require("animpicker")
local core = require("core")
local shadow = require("shadow")
local object = require("object")

local Josh = object()

function Josh:init(x, y)
  self.sprite = Sprite("assets/josh.ase")
  self.sprite:alignedOffset("center", "bottom")

  self.x = x
  self.y = y

  self.scalex = 1

  self.health = Health(self, 20, self.sprite)
  self:register(self.health)

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
  self.sm = StateMachine(self, self.idleState)

  self.body = core.ResolverBody(self, core.physics.rect(-5, -4, 10, 4), {
    mask = {"env"},
  })

  self.hitbox = core.SensorBody(self, core.physics.rect(-5, -12, 10, 12), {
    layers = {"enemy"},
  })
  core.physics.world:addBody(self.hitbox)
end

function Josh:removed()
  core.physics.world:removeBody(self.hitbox)
end

function Josh:onDied()
  core.world:remove(self)
end

function Josh:update(dt)
  self.sm:call("update", dt)
end

function Josh:idleUpdate()
  self.zIndex = self.y

  -- local mx, my = core.mainViewport:mousePos()
  local dirx, diry = math.cos(core.getRuntime() * 5), math.sin(core.getRuntime() * 5)
  local tag, scalex, _ = self.animPicker:pick(dirx, diry)

  self.scalex = scalex
  self.sprite:setActiveTag(tag, true)
  self.sprite:animate()

  shadow.queueDraw(self.sprite, self.x, self.y, self.scalex, 1)
end

function Josh:draw()
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y, 0, self.scalex, 1)
end

TiledMap.s_addSpawner("Josh", function(world, data)
  world:add(Josh(data.x, data.y))
end)

return Josh
