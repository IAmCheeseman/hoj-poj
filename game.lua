love.graphics.setDefaultFilter("nearest", "nearest")

local input = require("input")
local physics = require("physics")
local Viewport = require("viewport")
local World = require("world")
local DebugScreen = require("debugscreen")
local Player = require("player")

physics.initialize(0, 0)
mainvp = Viewport(320, 180)
guivp = Viewport(320 * 5, 180 * 5)
guivp.centered = false

world = World()
world:add(DebugScreen())

playerGroup = -1

envCategory = 1
playerCategory = 2
enemyCategory = 3

input.addAction("walk_up",    "kb", "w")
input.addAction("walk_left",  "kb", "a")
input.addAction("walk_down",  "kb", "s")
input.addAction("walk_right", "kb", "d")

local game = {}

function game.load()
  world:add(Player())
end

function game.update()
  physics.update()
  world:update()
end

function game.draw()
  mainvp:apply()
    love.graphics.clear(0.7, 0.7, 0.7)
    world:draw()
    love.graphics.setColor(1, 1, 1)
  mainvp:stop()

  guivp:apply()
    love.graphics.clear(0, 0, 0, 0)
    world:drawGui()
    love.graphics.setColor(1, 1, 1)
  guivp:stop()

  love.graphics.setColor(1, 1, 1)
  mainvp:draw()
  guivp:draw()
end

return game
