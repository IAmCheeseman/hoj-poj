local class = require("class")
local mathf = require("mathf")
local input = require("input")

local world

local physics = {}
local bodies = {}

function physics.initialize(gx, gy)
  world = love.physics.newWorld(gx, gy)
end

function physics.update()
  world:update(love.timer.getDelta())
end

function physics.diamondShape(...)
  local args = {...}
  local ox, oy, w, h
  if #args == 2 then
    ox, oy = 0, 0
    w = args[1]
    h = args[2]
  elseif #args == 4 then
    ox = args[1]
    oy = args[2]
    w = args[3]
    h = args[4]
  end

  return love.physics.newPolygonShape(
    ox, oy - h / 2,
    ox - w / 2, oy,
    ox, oy + h / 2,
    ox + w / 2, oy)
end

function physics.draw()
  local toRemove = {}
  for i, body in ipairs(bodies) do
    body:draw()
    if body.body:isDestroyed() then
      table.insert(toRemove, i)
    end
  end

  for i=#toRemove, 1, -1 do
    local pos = toRemove[i]

    local last = bodies[#bodies]
    bodies[pos] = last
    bodies[#bodies] = nil
  end
end

local drawFunctions = {
  ["CircleShape"] = function(body ,shape)
    love.graphics.setColor(1, 0, 0, 0.5)
    local x, y = body:getWorldCenter()
    love.graphics.circle("fill", x, y, shape:getRadius())
  end,
  ["PolygonShape"] = function(body ,shape)
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.polygon("fill", body:getWorldPoints(shape:getPoints()))
  end
}

local Body = class()
physics.Body = Body

function Body:init(anchor, type, shape)
  if not world then
    error("No world initialized.", 2)
  end

  self.anchor = anchor
  self.shape = shape
  self.type = type
  self.group = 0
  self.categories = 0x0000
  self.masks = 0x0000
  self.body = love.physics.newBody(world, anchor.x or 0, anchor.y or 0, type)
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.fixture:setFilterData(self.categories, self.masks, self.group)

  self:setBounce(0)

  table.insert(bodies, self)
end

function Body:getVelocity()
  return self.body:getLinearVelocity()
end

function Body:setVelocity(vx, vy)
  self.body:setLinearVelocity(vx, vy)
end

function Body:getPosition()
  return self.body:getPosition()
end

function Body:setPosition(x, y)
  self.body:setPosition(x, y)
end

function Body:getBounce()
  return self.fixture:getRestitution()
end

function Body:setBounce(bounce)
  self.fixture:setRestitution(bounce)
end

function Body:setCategory(category, to)
  self.categories = mathf.setBitTo(self.categories, category, to)
  self.fixture:setFilterData(self.categories, self.masks, self.group)
end

function Body:isInCategory(category)
  return mathf.getBit(self.categories, category)
end

function Body:setMask(mask, to)
  self.masks = mathf.setBitTo(self.masks, mask, to)
  self.fixture:setFilterData(self.categories, self.masks, self.group)
end

function Body:isMasked(mask)
  return not mathf.getBit(self.masks, mask)
end

function Body:setGroup(group)
  self.group = group
  self.fixture:setFilterData(self.categories, self.masks, self.group)
end

function Body:getGroup()
  return self.group
end

function Body:isFixedRotation()
  return self.body:isFixedRotation()
end

function Body:setFixedRotation(fixed)
  self.body:setFixedRotation(fixed)
end

function Body:draw()
  local drawFunc = drawFunctions[self.shape:type()]
  drawFunc(self.body, self.shape)
end

return physics
