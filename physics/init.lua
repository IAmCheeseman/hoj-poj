local PhysicsWorld = require("physics.physics_world")

local physics = {}

physics.world = PhysicsWorld()

physics.ResolverBody = require("physics.resolver_body")
physics.SensorBody = require("physics.sensor_body")

function physics.rect(x, y, w, h)
  if not w and not h then
    w = x
    h = y
    x = 0
    y = 0
  end

  return {
    x, y,
    x + w, y,
    x + w, y + h,
    x, y + h,
  }
end

function physics.circle(x, y, r)
  if not r then
    r = x
    x = 0
    y = 0
  end

  local vertices = {}

  local vertCount = (2 * math.pi * r) / 4

  for i=0, vertCount-1 do
    local angle = (i/vertCount) * math.pi * 2
    table.insert(vertices, x + math.cos(angle) * r)
    table.insert(vertices, y + math.sin(angle) * r)
  end

  return vertices
end

function physics.diamond(x, y, w, h)
  if not w and not h then
    w = x
    h = y
    x = 0
    y = 0
  end

  return {
    x, y - h / 2, -- Top
    x + w / 2, y, -- Right
    x, y + h / 2, -- Down
    x - w / 2, y, -- Left
  }
end

return physics
