local class = require("class")

local classMt = class.getDefaultMt()

local objectMt = {}
objectMt.__index = objectMt
objectMt.base = classMt.base

function objectMt:updateComponents()
  if type(self.components) ~= "table" then
    error("Components property has been tampered with.")
  end

  local dt = love.timer.getDelta()

  for _, component in ipairs(self.components) do
    if component.update then
      component:update(dt)
    end
  end
end

function objectMt:drawComponents()
  if type(self.components) ~= "table" then
    error("Components property has been tampered with.")
  end

  for _, component in ipairs(self.components) do
    if component.draw then
      component:draw()
    end
  end
end

function objectMt:register(...)
  local components = {...}
  for _, v in ipairs(components) do
    table.insert(self.components, v)
  end
end

function objectMt:__call(...)
  local t = {
    x = 0,
    y = 0,
    zIndex = 0,
    components = {},
  }
  return class.instance(self, t, ...)
end

local function object(inherits)
  return class.new(inherits, objectMt)
end

return object
