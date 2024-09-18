local map = require("world_gen.map")

local difficulty = 1

local enemies = {}

function addEnemyToSpawner(obj, chance, level)
  table.insert(enemies, {
    obj = obj,
    chance = chance,
    level = level,
  })
end

local function selectEnemy()
  local selection
  repeat
    selection = enemies[love.math.random(1, #enemies)]
  until love.math.random() < selection.chance
  return selection
end

function spawnEnemies(level)
  local px = 0
  local py = 0
  local player = world.getSingleton("player")
  if player then
    px = player.x
    py = player.y
  end

  local tilemap = world.getSingleton("tilemap_collision")
  if not tilemap then
    return
  end

  local enemyc = 15 + level * 3
  for _=1, enemyc do
    local x, y
    repeat
      x = love.math.random(map.sx, map.ex) * tilemap.tile_width
      y = love.math.random(map.sy, map.ey) * tilemap.tile_height
    until not tilemap:isPointOnTile(x, y) and vec.distanceSq(x, y, px, py) > (16 * 8)^2

    local enemy = selectEnemy().obj:create()
    enemy.x = x
    enemy.y = y
    world.add(enemy)
  end
end
