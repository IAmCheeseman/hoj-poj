local class = require("class")
local Body = require("physics.body")

local ResolverBody = class(Body)

function ResolverBody:init(anchor, w, h, options)
  self:base("init", "resolver", anchor, w, h, options)
end

function ResolverBody:resolve(other, velx, vely)
  if other == self then
    return velx, vely
  end

  local dt = love.timer.getDelta()

  local curx, cury = self:getPosition()
  local otherx, othery = other:getPosition()

  local futurex, futurey = curx + velx * dt, cury + vely * dt

  if Body.s_aabb(futurex, futurey, self.w, self.h,
                 otherx, othery, other.w, other.h) then
    if Body.s_aabbX(curx, self.w, otherx, other.w) then
      if vely > 0 then -- Down
        self.isOnFloor = true
        self.anchor.y = othery - self.h - self.offsety
      else -- Up
        self.isOnCeiling = true
        self.anchor.y = othery + other.h - self.offsety
      end
      vely = 0
    elseif Body.s_aabbY(cury, self.h, othery, other.h) then
      self.isOnWall = true
      if velx > 0 then -- Right
        self.isOnRightWall = true
        self.anchor.x = otherx - self.w - self.offsetx
      else -- Left
        self.isOnLeftWall = true
        self.anchor.x = otherx + other.w - self.offsetx
      end
      velx = 0
    end
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

  return velx, vely
end

function ResolverBody:getColor()
  return 0, 0, 1, 0.33
end

return ResolverBody
