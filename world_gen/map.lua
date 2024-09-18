local Walker = require("world_gen.walker")

local map = {}

local player_spawn_x = 0
local player_spawn_y = 0
local params = {}
local data = {}

local function initData()
  data = {}
  player_spawn_x = 0
  player_spawn_y = 0

  for x=1, params.map_width do
    table.insert(data, {})
    for _=1, params.map_height do
      table.insert(data[x], 1)
    end
  end
end

local function generateRoom()
  local padding = 50
  local walker = Walker.create(
    padding, padding,
    params.map_width - padding * 2, params.map_height - padding * 2)

  local first = true
  for p in walker:walkIter() do
    if p.x <= #data and p.y <= #data[1] then
      if love.math.random() < 0.05 or first then
        player_spawn_x = p.x
        player_spawn_y = p.y
        first = false
      end
      data[p.x][p.y] = 0
    end
  end
end

local function isSingle(x, y)
  local u = data[x][y-1] ~= 0
  local r = data[x+1][y] ~= 0
  local d = data[x][y+1] ~= 0
  local l = data[x-1][y] ~= 0

  local ur = data[x+1][y-1] ~= 0
  local ul = data[x-1][y-1] ~= 0
  local dr = data[x+1][y+1] ~= 0
  local dl = data[x-1][y+1] ~= 0

  if ul and u and l then return false end
  if ur and u and r then return false end
  if dr and d and r then return false end
  if dl and d and l then return false end

  return true
end

local function removeSingles()
  for x=2, #data-1 do
    for y=2, #data[x]-1 do
      if isSingle(x, y) then
        data[x][y] = 0
      end
    end
  end
end

local function renderToImage()
  local img_data = love.image.newImageData(params.map_width, params.map_height)
  local filled = {0, 0, 0, 1}
  local empty = {1, 1, 1, 1}

  for x=1, #data do
    for y=1, #data[x] do
      local cell = data[x][y]
      local color = cell == 0 and empty or filled
      img_data:setPixel(x - 1, y - 1, unpack(color))
    end
  end

  img_data:encode("png", "map.png")

  return love.graphics.newImage(img_data)
end

function map.generate(parameters)
  params = parameters

  initData()
  generateRoom()
  removeSingles()
  local img = renderToImage()

  return data, player_spawn_x, player_spawn_y, img
end

return map
