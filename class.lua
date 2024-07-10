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

function classMt:base(fnname, ...)
  local mt = getmetatable(self)
  local i = mt.__inherits
  if not i then
    error("No base class.", 1)
  end

  mt.__inherits = i.__inherits
  local res = i[fnname](self, ...)
  mt.__inherits = i

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
  __call = class.new
}

setmetatable(class, mt)

return class
