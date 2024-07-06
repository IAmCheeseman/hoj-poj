love.graphics.setDefaultFilter("nearest", "nearest")

local input = require("input")
local physics = require("physics")
local Viewport = require("viewport")
local World = require("world")
local DebugScreen = require("objects.debugscreen")
local TiledMap = require("tiled.map")
local autoload = require("autoload")

physics.initialize(0, 0)
mainViewport = Viewport(320, 180)
guiViewport = Viewport(320 * 5, 180 * 5)
guiViewport.centered = false

world = World()

playerGroup = -1

envCategory = 1
playerCategory = 2
enemyCategory = 3

autoload("objects/")

input.addAction("walk_up",    "kb", "w")
input.addAction("walk_left",  "kb", "a")
input.addAction("walk_down",  "kb", "s")
input.addAction("walk_right", "kb", "d")

local map = TiledMap(world, mainViewport, "assets/maps/start.lua")
world:add(DebugScreen())

local game = {}

function game.load()
end

function game.update()
  physics.update()
  world:update()
end

function game.draw()
  mainViewport:apply()
    -- love.graphics.clear(0, 0, 0)
    map:draw()
    world:draw()
    love.graphics.setColor(1, 1, 1)
  mainViewport:stop()

  guiViewport:apply()
    love.graphics.clear(0, 0, 0, 0)
    world:drawGui()
    love.graphics.setColor(1, 1, 1)
  guiViewport:stop()

  love.graphics.setColor(1, 1, 1)
  mainViewport:draw()
  guiViewport:draw()
end

return game
