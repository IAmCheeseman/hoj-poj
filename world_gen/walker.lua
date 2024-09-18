local Walker = {}
Walker.__index = Walker

function Walker.create(aabbx, aabby, aabbw, aabbh)
  local w = setmetatable({}, Walker)

  w.path = {}
  w.steps = 0
  w.steps_in_dir = 0
  w.x = math.floor(aabbx + aabbw / 2)
  w.y = math.floor(aabby + aabbh / 2)

  w.max_steps = 300
  w.dirx = 0
  w.diry = 0
  w.turn_chance = 0.15
  w.step_size_min = 1
  w.step_size_max = 1
  w.max_steps_per_dir = 5
  w.aabbx = aabbx
  w.aabby = aabby
  w.aabbw = aabbw
  w.aabbh = aabbh

  return w
end

function Walker:changeDirection()
  local newx = 0
  local newy = 0

  if love.math.random() < 0.5 then
    newx = love.math.random() < 0.5 and -1 or 1
  else
    newy = love.math.random() < 0.5 and -1 or 1
  end

  if newx == self.dirx and newy == self.diry then
    return Walker:changeDirection()
  end

  self.dirx = newx
  self.diry = newy

  self.steps_in_dir = 0
end

function Walker:canStepForward()
  local nextx = self.x + self.dirx
  local nexty = self.y + self.diry

  return nextx > self.aabbx
    and nexty > self.aabby
    and nextx < self.aabbx + self.aabbw
    and nexty < self.aabby + self.aabbh
end

function Walker:step()
  self.x = self.x + self.dirx
  self.y = self.y + self.diry

  local points = {}
  local step_size = love.math.random(self.step_size_min, self.step_size_max)
  for x=1, step_size do
    for y=1, step_size do
      table.insert(self.path, {x=self.x+x, y=self.y+y})
      table.insert(points, {x=self.x+x, y=self.y+y})
    end
  end

  self.steps = self.steps + 1
  self.steps_in_dir = self.steps_in_dir + 1

  return points
end

function Walker:doStep()
  if self:canStepForward() then
    local p = self:step()

    if self.steps_in_dir >= self.max_steps_per_dir
      or love.math.random() < self.turn_chance then
      self:changeDirection()
    end

    return p
  end

  self:changeDirection()
  return self:doStep()
end

function Walker:walk()
  while self.steps < self.max_steps do
    self:doStep()
  end
end

function Walker:walkIter()
  local k = nil
  local points = self:doStep()

  return function()
    if self.steps >= self.max_steps then
      return nil
    end

    local v
    k, v = next(points, k)
    if not v then
      points = self:doStep()
      k, v = next(points, nil)
    end

    return v
  end
end

return Walker
