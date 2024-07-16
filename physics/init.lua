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

return physics
