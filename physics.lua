local Body = {}
Body.__index = Body

local function verifyAnchor(anchor, errIndex)
  errIndex = errIndex + 1

  local requiredProperties = {
    x = "number",
    y = "number",
  }

  for k, requiredType in pairs(requiredProperties) do
    local keyType = type(anchor[k])
    if keyType ~= requiredType then
      error(
        ("Anchor requires '%s' to be %s, got %s."):format(
          k, requiredType, keyType),
        errIndex)
    end
  end
end

function Body.create(anchor, shape)
  verifyAnchor(anchor, 0)

  if not love.math.isConvex(shape) then
    error("Shape must be convex")
  end

  local b = setmetatable({}, Body)

  b.anchor = anchor
  b.shape = shape

  return b
end

function Body:getAabb()
  if self.aabbx and self.aabby and self.aabbw and self.aabbh then
    return
      self.aabbx + self.anchor.x, self.aabby + self.anchor.y,
      self.aabbw, self.aabbh
  end

  local startx, starty = self.shape[1] , self.shape[2]
  local endx, endy = startx, starty

  for i=1, #self.shape, 2 do
    local x, y = self.shape[i], self.shape[i+1]

    startx = math.min(startx, x)
    starty = math.min(starty, y)
    endx = math.max(endx, x)
    endy = math.max(endy, y)
  end

  self.aabbx = startx
  self.aabby = starty
  self.aabbw = endx-startx
  self.aabbh = endy-starty
  return
    self.aabbx + self.anchor.x, self.aabby + self.anchor.y,
    self.aabbw, self.aabbh
end

function Body:getSmallestSide()
  local _, _, w, h = self:getAabb()
  return math.min(w, h)
end

function Body:getCenter()
  if self.centerx and self.centery then
    return self.centerx + self.anchor.x, self.centery + self.anchor.y
  end

  local total_points = #self.shape / 2

  local sumx = 0
  local sumy = 0

  for i=1, #self.shape, 2 do
    sumx = sumx + self.shape[i]
    sumy = sumy + self.shape[i+1]
  end

  self.centerx = sumx / total_points
  self.centery = sumy / total_points

  return self.centerx + self.anchor.x, self.centery + self.anchor.y
end

local function project(body, axisx, axisy)
  local min = vec.dot(
    axisx, axisy, body.shape[1] + body.anchor.x, body.shape[2] + body.anchor.y)
  local max = min

  for i=1, #body.shape, 2 do
    local p = vec.dot(
      axisx, axisy,
      body.shape[i] + body.anchor.x, body.shape[i+1] + body.anchor.y)

    if p < min then
      min = p
    elseif p > max then
      max = p
    end
  end

  return {min=min, max=max}
end

local function sat(a, b, check, res)
  for i=1, #check.shape, 2 do
    local startx = check.shape[i] + check.anchor.x
    local starty = check.shape[i+1] + check.anchor.y

    local endx, endy

    if i + 2 > #check.shape then
      endx = check.shape[1] + check.anchor.x
      endy = check.shape[2] + check.anchor.y
    else
      endx = check.shape[i+2] + check.anchor.x
      endy = check.shape[i+3] + check.anchor.y
    end


    local axisx = -(starty - endy)
    local axisy = startx - endx
    axisx, axisy = vec.normalized(axisx, axisy)

    local a_proj = project(a, axisx, axisy)
    local b_proj = project(b, axisx, axisy)
    -- We found the gap between the shapes
    if a_proj.max < b_proj.min or b_proj.max < a_proj.min then
      res.colliding = false
      return res
    end

    -- No gap so far, tell how to move out with minimum offset
    local overlap = math.min(a_proj.max - b_proj.min, b_proj.max - a_proj.min)
    if overlap < res.overlap then
      res.overlap = overlap
      res.axisx = axisx
      res.axisy = axisy
    end
  end

  return res
end

local function rcTestAxis(axisx, axisy, sx, sy, ex, ey, body)
  local rcProjMin = vec.dot(axisx, axisy, sx, sy)
  local rcProjMax = vec.dot(axisx, axisy, ex, ey)
  if rcProjMin > rcProjMax then
    rcProjMin, rcProjMax = rcProjMax, rcProjMin
  end

  local proj = project(body, axisx, axisy)
  if rcProjMax > proj.min and proj.max > rcProjMin then
    return true
  end
  return false
end

function raycast(sx, sy, ex, ey, tags)
  local coll = {
    colliding = false,
  }

  local dirx, diry = ex - sx, ey - sy
  local rc_perp_x = -diry
  local rc_perp_y = dirx

  local rc_par_x = dirx
  local rc_par_y = diry

  for _, tag in ipairs(tags) do
    local tagged = world.getTagged(tag)
    if #tagged == 0 then
      return
    end

    for _, obj in ipairs(tagged) do
      local body = obj.body
      local body_checks_passed = true
      for i=1, #body.shape, 2 do
        local startx = body.shape[i] + body.anchor.x
        local starty = body.shape[i+1] + body.anchor.y

        local endx, endy

        if i + 2 > #body.shape then
          endx = body.shape[1] + body.anchor.x
          endy = body.shape[2] + body.anchor.y
        else
          endx = body.shape[i+2] + body.anchor.x
          endy = body.shape[i+3] + body.anchor.y
        end


        local axisx = -(starty - endy)
        local axisy = startx - endx
        axisx, axisy = vec.normalized(axisx, axisy)

        if not rcTestAxis(axisx, axisy, sx, sy, ex, ey, body) then
          body_checks_passed = false
          break
        end
      end

      if body_checks_passed
      and rcTestAxis(rc_perp_x, rc_perp_y, sx, sy, ex, ey, body)
      and rcTestAxis(rc_par_x, rc_par_y, sx, sy, ex, ey, body) then
        coll.colliding = true
        coll.obj = obj
        return coll
      end
    end
  end

  return coll
end

function Body:collideWithBody(body)
  local res = {
    colliding = true,
    resolvex = 0,
    resolvey = 0,
    axisx = 0,
    axisy = 0,
    overlap = math.huge,
  }

  sat(self, body, self, res)
  if res.colliding then
    sat(self, body, body, res)
  end

  res.resolvex = res.axisx * res.overlap
  res.resolvey = res.axisy * res.overlap

  local scx, scy = self:getCenter()
  local ocx, ocy = body:getCenter()
  local dirx, diry = vec.direction(ocx, ocy, scx, scy)
  if vec.dot(dirx, diry, res.resolvex, res.resolvey) < 0 then
    res.resolvex = -res.resolvex
    res.resolvey = -res.resolvey
  end

  return res
end

function Body:_moveAndCollideWithTag(tag)
  local tagged = world.getTagged(tag)
  if #tagged == 0 then
    return
  end

  local coll

  for _, obj in ipairs(tagged) do
    local res = self:collideWithBody(obj.body)
    if res.colliding then
      self.anchor.x = self.anchor.x + res.resolvex
      self.anchor.y = self.anchor.y + res.resolvey

      coll = res
    end
  end

  return coll
end

function Body:moveAndCollideWithTags(vx, vy, dt, tags)
  local coll

  local ax, ay = self.anchor.x, self.anchor.y
  local movex = vx * dt
  local movey = vy * dt
  local resx = ax + movex
  local resy = ay + movey

  local dist = vec.distance(self.anchor.x, self.anchor.y, resx, resy)
  local checks = math.ceil(dist / self:getSmallestSide())

  for i=1, checks do
    local p = i/checks
    self.anchor.x = ax + movex * p
    self.anchor.y = ay + movey * p

    for _, tag in ipairs(tags) do
      coll = self:_moveAndCollideWithTag(tag)
      if coll and coll.colliding then
        return coll
      end
    end
  end

  return coll
end

function Body:getAllCollisions(vx, vy, dt, tags)
  local collisions = {}
  local added_set = {}

  local ax, ay = self.anchor.x, self.anchor.y
  local movex = vx * dt
  local movey = vy * dt
  local resx = ax + movex
  local resy = ay + movey

  local dist = vec.distance(self.anchor.x, self.anchor.y, resx, resy)
  local checks = math.ceil(dist / self:getSmallestSide())

  for i=1, checks do
    local p = i/checks
    self.anchor.x = ax + movex * p
    self.anchor.y = ay + movey * p

    for _, tag in ipairs(tags) do
      for _, obj in ipairs(world.getTagged(tag)) do
        local res = self:collideWithBody(obj.body)
        if res.colliding and not added_set[obj] then
          added_set[obj] = true

          res.tag = tag
          res.obj = obj
          table.insert(collisions, res)
        end
      end
    end
  end

  self.anchor.x = ax
  self.anchor.y = ay

  return collisions
end

function Body:getVertices()
  local worldVert = {}
  for i=1, #self.shape, 2 do
    table.insert(worldVert, self.shape[i] + self.anchor.x)
    table.insert(worldVert, self.shape[i + 1] + self.anchor.y)
  end
  return worldVert
end

function Body:draw()
  local vertices = self:getVertices()

  love.graphics.setColor(1, 0, 0, 0.5)
  love.graphics.polygon("line", vertices)
end

function Body:drawLocal()
  love.graphics.setColor(1, 0, 0, 0.5)
  love.graphics.polygon("line", self.shape)
end

return Body
