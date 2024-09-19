local Walker = require("world_gen.walker")

local map = {}

local player_spawn_x = 0
local player_spawn_y = 0
local params = {}
local data = {}
local sx, sy, ex, ey = -1, -1, -1, -1

local function initData()
  data = {}
  player_spawn_x = 0
  player_spawn_y = 0
  sx = -1

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

  for k, v in pairs(params.walker or {}) do
    walker[k] = v
  end

  for p in walker:walkIter() do
    if p.x <= #data and p.y <= #data[1] then
      if sx == -1 then
        sx = p.x
        sy = p.y
        ex = p.x
        ey = p.y
      else
        sx = math.min(sx, p.x)
        sy = math.min(sy, p.y)
        ex = math.max(ex, p.x)
        ey = math.max(ey, p.y)
      end

      player_spawn_x = p.x
      player_spawn_y = p.y
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
  local iw, ih = ex - sx, ey - sy
  local img_data = love.image.newImageData(iw, ih)
  local filled = {0, 0, 0, 0}
  local empty = {1, 1, 1, 1}

  for dx=sx, ex-1 do
    for dy=sy, ey-1 do
      local cell = data[dx][dy]
      local color = cell == 0 and empty or filled
      local x, y = dx - sx, dy - sy
      img_data:setPixel(x, y, unpack(color))
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

  map.img = img

  map.sx = sx
  map.sy = sy
  map.ex = ex
  map.ey = ey

  return data, player_spawn_x, player_spawn_y, img
end

return map
