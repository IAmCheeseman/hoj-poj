local Room = require("room")
local map = require("world_gen.map")

Forest = Room.create()

function Forest:init(args)
  if args.new_run then
    resetAmmo()
    resetKillTimer()
    resetDifficulty()
    resetPlayerData()
  else
    nextDifficulty()
  end

  local player = Player:create()
  world.add(player)
  world.add(BloodLayer:create())
  world.add(Background:create("assets/grass.png"))
  world.add(DroppedWeapon:create("swiss_rifle", -50, 50))

  local map_data, px, py, _ = map.generate({
    map_width = 200,
    map_height = 200,
    walker = {
      max_steps = 250,
      turn_chance = 0.15,
      step_distance = 3,
      step_size_min = 1,
      step_size_max = 1,
      max_steps_per_dir = 3,
    }
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

  world.flush()
  world.flush()

  spawnEnemies()
end
