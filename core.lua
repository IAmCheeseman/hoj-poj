local Viewport = require("viewport")
local World = require("world")
local shadow = require("shadow")
local Event = require("event")

local core = {}

core.mainViewport = Viewport(320, 180)
core.guiViewport = Viewport(320 * 5, 180 * 5)
core.guiViewport.centered = false

core.playerGroup = -1

core.envCategory = 1
core.playerCategory = 2
core.enemyCategory = 3

core.world = World()
core.vec = require("vec")
core.math = require("mathf")
core.input = require("input")
core.physics = require("physics")
core.ResolverBody = core.physics.ResolverBody
core.SensorBody = core.physics.SensorBody

core.update = Event()
core.postUpdate = Event()
core.draw = Event()
core.gui = Event()
core.postDraw = Event()

shadow.init(core.world, core.mainViewport)

return core
