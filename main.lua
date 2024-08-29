max_fps = 30
tick_rate = 1/max_fps
total_time = 0

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")
require("util")

struct = require("struct")
viewport = require("viewport")
sound = require("sound")
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

require("translations")
require("score")
require("kill_timer")
require("spawner")

local modding = require("modding")
modding.loadMods()

local update_graphics = false
local frame = 0

local player = Player:create()
player.sprite.a = 0
world.add(player)

world.add(Cursor:create())
world.add(PauseScreen:create())
world.add(BloodLayer:create())
world.add(Background:create("assets/grass.png"))
world.add(DroppedWeapon:create("swiss_rifle", -50, 50))

local map = require("world_gen.map")
local map_data, px, py, _ = map.generate({
  min_rooms = 4,
  max_rooms = 4,
  map_width = 200,
  map_height = 200,
  room_width = 20,
  room_height = 20,
})

local tilemap = Tilemap:create(
  map_data, love.graphics.newImage("assets/dirt_tiles.png"), 16, 16, {
    [1]  = {0, 0,   8, 0,   0, 8                          },
    [2]  = {8, 0,   16, 0,  16, 8                         },
    [3]  = {0, 0,   16, 0,  16, 8,   0, 8                 },
    [4]  = {16, 8,  16, 16, 7, 16                         },
    [5]  = {0, 0,   8, 0,   16, 8,   16, 16,  8, 16,  0, 8},
    [6]  = {8, 0,   16, 0,  16, 16,  8, 16                },
    [7]  = {0, 0,   16, 0,  16, 16,  8, 16,   0, 8        },
    [8]  = {0, 8,   9, 16,  0, 16                         },
    [9]  = {0, 0,   8, 0,   8, 16,   0, 16                },
    [10] = {8, 0,   16, 0,  16, 8,   8, 16,   0, 16,  0, 8},
    [11] = {0, 0,   16, 0,  16, 8,   8, 16,   0, 16       },
    [12] = {0, 8,   16, 8,  16, 16,  0, 16                },
    [13] = {0, 0,   8, -1,  16, 8,   16, 16,  0, 16       },
    [14] = {8, -1,  16, 0,  16, 16,  0, 16,   0, 8        },
  })
table.insert(tilemap.tags, "tilemap_collision")
tilemap.has_shadows = true
world.add(tilemap)

local tilemap_cover = Tilemap:create(
  map_data, love.graphics.newImage("assets/grass_tiles.png"), 16, 16, {})
tilemap_cover.y = -8
tilemap_cover.show_above = true
world.add(tilemap_cover)

player.x = px * tilemap.tile_width
player.y = py * tilemap.tile_height

function love.update(dt)
  total_time = total_time + dt

  frame = frame - tick_rate

  action.step()
  modding.step()

  world.update(dt)

  stepCombo(dt)
  stepSpawnTimer(dt)
  stepKillTimer(dt)

  modding.postStep()
  camera.step(dt)

  world.flush()

  update_graphics = true
end

function love.draw()
  if update_graphics then
    update_graphics = false

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
