local physics = require("physics")
local Viewport = require("viewport")
local World = require("world")
local shadow = require("shadow")
local autoload = require("autoload")

local core = {}

physics.initialize(0, 0)
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
core.Body = core.physics.Body

shadow.init(core.world, core.mainViewport)

return core
