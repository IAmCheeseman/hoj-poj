local class = require("class")
local vec = require("vec")
local stats = require("physics.stats")
local Body = require("physics.body")

local ResolverBody = class(Body)

function ResolverBody:init(anchor, w, h, options)
  self:base("init", "resolver", anchor, w, h, options)
end

function ResolverBody:resolve(other, velx, vely)
  if other == self or other.type == "sensor" then
    return velx, vely
  end

  local collision = Body.s_sat(self, other)

  if collision.overlaps then
    self.anchor.x = self.anchor.x + collision.resolvex
    self.anchor.y = self.anchor.y + collision.resolvey
    stats.resolutions = stats.resolutions + 1
  end

  return velx, vely
end

function ResolverBody:moveAndCollide(velx, vely)
  local dt = love.timer.getDelta()

  self.isOnFloor = false
  self.isOnCeiling = false
  self.isOnWall = false
  self.isOnLeftWall = false
  self.isOnRightWall = false

  local neighborChunks = self.world.chunker:getNeighborChunks(self)

  for _, chunk in ipairs(neighborChunks) do
    for _, body in ipairs(chunk) do
      if self:canCollideWith(body) then
        velx, vely = self:resolve(body, velx, vely)
      end
    end
  end

  self.anchor.x = self.anchor.x + velx * dt
  self.anchor.y = self.anchor.y + vely * dt

  self.world.chunker:updateBody(self)

  if vec.length(velx, vely) < 5 then
    velx = 0
    vely = 0
  end

  return velx, vely
end

function ResolverBody:getColor()
  return 0, 0, 1, 0.33
end

return ResolverBody
