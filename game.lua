local shadow = require "shadow"
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
input.addAction("toggle_collisions", "kb", "f2")

shadow.init(world, mainViewport)

local curriedShadowDraw = function(drawable, x, y, _, sx, sy)
  shadow.queueDrawGeneric(love.graphics.draw, drawable, x, y, sx, sy, true)
end

local map = TiledMap(world, mainViewport, "assets/maps/start.lua", {
  layer = function(layer, data)
    if data.properties.isShadow then
      layer.drawFunc = curriedShadowDraw
    end
  end
})
world:add(DebugScreen())

local game = {}

local drawCollisions = false

input.actionTriggered:on(function(action, _, isRepeat)
  if action == "toggle_collisions" and not isRepeat then
    drawCollisions = not drawCollisions
  end
end)

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
    if drawCollisions then
      physics.draw()
    end

    shadow.renderAll()
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
