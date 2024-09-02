BloodLayer = struct()

local splat_count = 9
local splats_img = love.graphics.newImage("assets/blood_splats.png")
local batch = love.graphics.newSpriteBatch(splats_img)
local splats = {}

do
  local splatw = splats_img:getWidth() / splat_count
  for i=1, splat_count do
    local x = i - 1
    local q = love.graphics.newQuad(
      x * splatw, 0,
      splatw, splats_img:getHeight(),
      splats_img:getDimensions())
    table.insert(splats, q)
  end
end

local blood_types = {}

function addBloodType(name, start_idx, end_idx)
  blood_types[name] = {
    start_idx = start_idx,
    end_idx = end_idx,
  }
end

addBloodType("earthling", 1, 3)
addBloodType("alien", 4, 6)
addBloodType("demon", 7, 9)

function addBloodSplat(blood_type, x, y, count, spread)
  count = count or 1
  spread = spread or 16

  for _=1, count do
    local direction = mathx.frandom(0, mathx.tau)
    local dx = x + mathx.frandom(-spread, spread)
    local dy = y + mathx.frandom(-spread, spread)

    local blood = blood_types[blood_type]
    local splat = splats[love.math.random(blood.start_idx, blood.end_idx)]
    batch:add(splat, dx, dy, direction, 1, 1, 8, 8)
  end
end

function BloodLayer:draw()
  self.z_index = -1

  love.graphics.draw(batch)
end
