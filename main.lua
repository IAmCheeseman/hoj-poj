love.graphics.setDefaultFilter("nearest", "nearest")

local class = require("class")
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

playerGroup = -1

envCategory = 1
playerCategory = 2
enemyCategory = 3

input.addAction("walk_up",    "kb", "w")
input.addAction("walk_left",  "kb", "a")
input.addAction("walk_down",  "kb", "s")
input.addAction("walk_right", "kb", "d")

local Block = class()

function Block:init(x, y)
  self.x = x
  self.y = y

  self.body = physics.Body(
    self, "static", love.physics.newRectangleShape(20, 30))
  self.body:setCategory(envCategory, true)
  self.body:setMask(playerCategory, true)
  self.body:setMask(enemyCategory, true)
end

function Block:draw()
  self.body:draw()
end


local player = Player()
player.body:setPosition(320 / 2, 180 / 2)
world:add(player)
world:add(Block(50, 50))
world:add(DebugScreen())

function love.update()
  physics.update()
  world:update()
end

function love.draw()
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
