local difficulty = 1
local base_time = 10

local spawn_timer = base_time

local enemies = {
  {
    obj = Hammerhead,
    chance = 1,
  }
}

local function getSpawnTime()
  return math.floor(base_time / (difficulty / 3))
end

function stepSpawnTimer()
  spawn_timer = spawn_timer - 1

  if spawn_timer <= 0 then
    spawn_timer = getSpawnTime()

    local selection
    repeat
      selection = enemies[love.math.random(1, #enemies)]
    until love.math.random() < selection.chance

    local player = world.getSingleton("player")
    if player then
      local enemy = selection.obj:create()

      local tilemap = world.getSingleton("tilemap")
      if not tilemap then
        return
      end

      local x, y
      repeat
        x = viewport.camx + love.math.random(-50, viewport.screenw + 50)
        y = viewport.camy + love.math.random(-50, viewport.screenh + 50)
      until not tilemap:isPointOnTile(x, y) and not viewport.isPointOnScreen(x, y)

      enemy.x = x
      enemy.y = y
      world.add(enemy)
    end
  end
end
