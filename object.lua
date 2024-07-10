local class = require("class")

local classMt = class.getDefaultMt()

local objectMt = {}
objectMt.__index = objectMt
objectMt.base = classMt.base

function objectMt:__call(...)
  local t = {
    x = 0,
    y = 0,
    zIndex = 0,
  }
  return class.instance(self, t, ...)
end

local function object(inherits)
  return class.new(inherits, objectMt)
end

return object
