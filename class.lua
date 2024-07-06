local classMt = {}
classMt.__index = classMt

function classMt:__call(...)
  local inst = setmetatable({}, self)
  if inst.init then
    inst:init(...)
  end
  return inst
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

local function class(inherits)
  local c = setmetatable({}, classMt)

  if inherits then
    for k, v in pairs(inherits) do
      c[k] = v
    end

    c.__inherits = inherits
  end

  c.__index = c

  return c
end

return class
