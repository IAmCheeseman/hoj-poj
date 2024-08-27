BloodLayer = struct()

local splat_count = 3
local splats_img = love.graphics.newImage("assets/blood_splats.png")
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

function addBloodType(name, color)
  blood_types[name] = {
    batch = love.graphics.newSpriteBatch(splats_img),
    color = color,
  }
end

addBloodType("earthling", {0.7, 0.1, 0.2})
addBloodType("alien", {0.1, 0.5, 0.7})

function addBloodSplat(blood_type, x, y, count, spread)
  count = count or 1
  spread = spread or 16

  for _=1, count do
    local direction = mathx.frandom(0, mathx.tau)
    local dx = x + mathx.frandom(-spread, spread)
    local dy = y + mathx.frandom(-spread, spread)

    local splat = splats[love.math.random(1, #splats)]
    local blood = blood_types[blood_type]
    blood.batch:add(splat, dx, dy, direction, 1, 1, 8, 8)
  end
end

function BloodLayer:draw()
  self.z_index = viewport.camy

  for _, blood in pairs(blood_types) do
    love.graphics.setColor(blood.color)
    love.graphics.draw(blood.batch)
  end
end
