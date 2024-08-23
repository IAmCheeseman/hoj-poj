local function create(s, ...)
  local inst = setmetatable({}, s)
  local _ = try(inst.new, inst, ...)

  return inst
end

local function struct()
  local s = {}
  s.__index = s
  s.create = create
  return s
end

return struct
