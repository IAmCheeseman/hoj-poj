local Walker = require("world_gen.walker")

local map = {}

local player_spawn_x = 0
local player_spawn_y = 0
local params = {}
local data = {}

local function initData()
  for x=1, params.map_width do
    table.insert(data, {})
    for _=1, params.map_height do
      table.insert(data[x], 1)
    end
  end
end

local function roomCanFit(x, y)
  return x + params.room_width < params.map_width - params.room_width
    and y + params.room_height < params.map_height - params.room_height
    and x > params.room_width
    and y > params.room_height
end

local function findStartingRoomPos()
  local x, y = 0, 0
  while not roomCanFit(x, y) do
    x = love.math.random(0, params.map_width)
    y = love.math.random(0, params.map_height)
  end

  return x, y
end

local function findNextRoomPos(oldx, oldy, other_rooms)
  -- Try to find a new room pos 20 times, give up after that and call it good
  for _=1, 20 do
    local dirx = 0
    local diry = 0
    if love.math.random() < 0.5 then
      dirx = love.math.random() < 0.5 and -1 or 1
    else
      diry = love.math.random() < 0.5 and -1 or 1
    end

    local nextx = oldx + dirx * params.room_width
    local nexty = oldy + diry * params.room_height

    -- Abs doesn't really matter
    local axisx = math.abs(-(oldy - nexty))
    local axisy = math.abs(oldx - nextx)
    axisx, axisy = vec.normalized(axisx, axisy)

    local max_shift_x = params.room_width / 2
    nextx = nextx + axisx * love.math.random(-max_shift_x, max_shift_x)
    local max_shift_y = params.room_height / 2
    nexty = nexty + axisy * love.math.random(-max_shift_y, max_shift_y)

    local overlapping_other = false
    for _, r_pos in ipairs(other_rooms) do
      -- 1|  2| 1|  2|
      overlapping_other =
            r_pos.x < nextx + params.room_width
        and r_pos.y < nextx + params.room_height
        and nextx < r_pos.x + params.room_width
        and nexty < r_pos.x + params.room_height

      if overlapping_other then
        break
      end
    end

    if not overlapping_other and roomCanFit(nextx, nexty) then
      return true, nextx, nexty
    end
  end

  return false
end

local function connectPoints(fx, fy, tx, ty)
  fx = math.floor(fx)
  fy = math.floor(fy)
  tx = math.floor(tx)
  ty = math.floor(ty)

  local dirx, diry = vec.direction(fx, fy, tx, ty)
  dirx = mathx.sign(dirx)
  diry = mathx.sign(diry)

  -- Connect it first on one axis, then on the other
  local x, y = fx, fy

  while x ~= tx do
    x = math.floor(x + dirx)

    data[x][y] = 0
    data[x+1][y] = 0
    data[x][y+1] = 0
    data[x+1][y+1] = 0

    player_spawn_x = x
    player_spawn_y = y
  end

  while y ~= ty do
    y = math.floor(y + diry)

    data[x][y] = 0
    data[x+1][y] = 0
    data[x][y+1] = 0
    data[x+1][y+1] = 0

    player_spawn_x = x
    player_spawn_y = y
  end
end

local function generateRooms()
  local room_positions = {}

  local x, y = findStartingRoomPos()

  table.insert(room_positions, {x=x, y=y})

  -- Subtract 1 because we already found a place for one
  local room_count = love.math.random(params.min_rooms, params.max_rooms) - 1

  for i=1, room_count do
    local ok
    ok, x, y = findNextRoomPos(x, y, room_positions)
    if ok then
      table.insert(room_positions, {x=x, y=y})
    else
      room_count = i
      break
    end
  end

  -- We found where all the rooms go, now generate the connections between them
  for i=1, #room_positions-1 do
    local from = room_positions[i]
    local to = room_positions[i+1]
    connectPoints(
      from.x + params.room_width / 2, from.y + params.room_height / 2,
      to.x + params.room_width / 2, to.y + params.room_height / 2)
  end

  for _, r_pos in ipairs(room_positions) do
    local walker = Walker.create(
      r_pos.x, r_pos.y, params.room_width, params.room_height)
    for p in walker:walkIter() do
      if p.x <= #data and p.y <= #data[1] then
        data[p.x][p.y] = 0
      end
    end

    local last = walker.path[#walker.path]
    local lock = SafehouseLock:create(last.x * 16 + 8, last.y * 16 + 8)
    world.add(lock)
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

function map.generate(parameters)
  params = parameters

  initData()
  generateRooms()
  removeSingles()

  for k, v in pairs(data) do
    if not v then
      data[k] = nil
    end
  end

  return data, player_spawn_x, player_spawn_y
end

return map
