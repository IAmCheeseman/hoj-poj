local PhysicsWorld = require("physics.physics_world")

local physics = {}

physics.world = PhysicsWorld()

physics.ResolverBody = require("physics.resolver_body")

return physics
