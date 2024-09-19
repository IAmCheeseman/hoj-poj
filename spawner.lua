local map = require("world_gen.map")

local difficulty = 0

local enemies = {}

function nextDifficulty()
  difficulty = difficulty + 1
end

function getDifficulty()
  return difficulty
end

function resetDifficulty()
  difficulty = 1
end

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
  until love.math.random() < selection.chance and difficulty >= selection.level
  return selection
end

local function spawnPointIsValid(x, y, tilemap)
  return
        not tilemap:isPointOnTile(x, y)
    and not tilemap:isPointOnTile(x + tilemap.tile_width, y)
    and not tilemap:isPointOnTile(x, y + tilemap.tile_height)
    and not tilemap:isPointOnTile(x - tilemap.tile_width, y)
    and not tilemap:isPointOnTile(x, y - tilemap.tile_height)
end

function spawnEnemies()
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

  local spawn_positions = {}
  for x=map.sx, map.ex, 1 do
    for y=map.sy, map.ey, 1 do
      local rx, ry = x * tilemap.tile_width, y * tilemap.tile_height
      if spawnPointIsValid(rx, ry, tilemap)
      and vec.distanceSq(rx, ry, px, py) > (16*4)^2 then
        table.insert(spawn_positions, {rx, ry})
      end
    end
  end

  local enemyc = 5 + (difficulty - 1) * 2
  for _=1, enemyc do
    local i = love.math.random(1, #spawn_positions)
    local pos = spawn_positions[i]

    if #spawn_positions > 5 then
      tablex.swapRem(spawn_positions, i)
    end

    local enemy = selectEnemy().obj:create()
    enemy.x = pos[1]
    enemy.y = pos[2]
    world.add(enemy)
  end
end
