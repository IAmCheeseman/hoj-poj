love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")
require("util")

require("translations")
require("score")

struct = require("struct")
viewport = require("viewport")
world = require("world")
action = require("action")
vec = require("vec")
Body = require("physics")
shape = require("polygon_shapes")
Sprite = require("sprite")
camera = require("camera")
log = require("log")

local loadDirectory = require("load_directory")
loadDirectory("objects")
loadDirectory("functions")
loadDirectory("states")

local modding = require("modding")
modding.loadMods()

max_fps = 30
tick_rate = 1/max_fps
total_time = 0

local update_graphics = false
local frame = 0

local player = Player:create()

world.add(BloodLayer:create())
world.add(player)
world.add(Background:create("assets/grass.png"))
world.add(DroppedWeapon:create("swiss_rifle", -50, 50))

for _=1, 20 do
  local e = Hammerhead:create()
  e.x = love.math.random(100, 200)
  e.y = love.math.random(100, 200)
  world.add(e)
end

local map = require("world_gen.map")
local map_data, px, py = map.generate({
  min_rooms = 4,
  max_rooms = 4,
  map_width = 512,
  map_height = 512,
  room_width = 35,
  room_height = 35,
})

local tilemap = Tilemap:create(
  map_data, love.graphics.newImage("assets/tileset_base.png"), 16, 16)
world.add(tilemap)

player.x = px * tilemap.tile_width
player.y = py * tilemap.tile_height

function love.update(dt)
  frame = frame + dt
  if frame >= tick_rate then
    total_time = total_time + 1

    frame = frame - tick_rate

    action.step()
    modding.step()

    world.update()

    stepCombo()

    modding.postStep()
    camera.step()

    world.flush()

    update_graphics = true
  end
end

function love.draw()
  if update_graphics then
    viewport.apply()
    love.graphics.clear(0.05, 0.55, 0.45)
    world.draw()

    love.graphics.push()
    love.graphics.origin()
    love.graphics.print(love.timer.getFPS())
    love.graphics.print(("(%d, %d)"):format(player.x, player.y), 0, 8)
    love.graphics.pop()

    viewport.stop()
  end

  love.graphics.setColor(1, 1, 1)
  viewport.draw()
end
