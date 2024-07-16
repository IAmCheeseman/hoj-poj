local class = {}

function class.instance(c, t, ...)
  local inst = setmetatable(t, c)
  if inst.init then
    inst:init(...)
  end
  return inst
end


local classMt = {}
classMt.__index = classMt

function classMt:__call(...)
  return class.instance(self, {}, ...)
end

function classMt:base(funcName, ...)
  local mt = getmetatable(self)
  local base = mt.__inherits
  if not base then
    error("No base class.", 1)
  end

  mt.__inherits = base.__inherits
  local fn = base[funcName]
  local res = nil
  if fn then
    res = fn(self, ...)
  else
    error("No function '" .. funcName .. "' in base class.")
  end
  mt.__inherits = base

  return res
end


function class.new(inherits, mt)
  mt = mt or classMt

  local c = setmetatable({}, mt)

  if inherits then
    for k, v in pairs(inherits) do
      c[k] = v
    end

    c.__inherits = inherits
  end

  c.__index = c

  return c
end

function class.getDefaultMt()
  return classMt
end

local mt = {
  __call = function(_, ...)
    return class.new(...)
  end
}

setmetatable(class, mt)

return class
