require("error_handler")

local Viewport = require("viewport")
local World = require("world")
local shadow = require("shadow")
local Event = require("event")

local log = require("log")

local core = {}

core.mainViewport = Viewport(240, 180)
core.guiViewport = Viewport(240, 180)
core.guiViewport.centered = false

core.playerGroup = -1

core.envCategory = 1
core.playerCategory = 2
core.enemyCategory = 3

core.world = World()
core.vec = require("vec")
core.math = require("mathf")
core.input = require("input")
core.log = log
core.physics = require("physics")
core.ResolverBody = core.physics.ResolverBody
core.SensorBody = core.physics.SensorBody

core.update = Event()
core.postUpdate = Event()
core.draw = Event()
core.gui = Event()
core.postDraw = Event()

shadow.init(core.world, core.mainViewport)

local runtime = 0

function core.getRuntime()
  return runtime
end

core.update:on(function(dt)
  runtime = runtime + dt
end)

return core
