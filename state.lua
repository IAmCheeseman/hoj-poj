local function create(s, anchor, ...)
  local inst = setmetatable({}, s)

  inst.anchor = anchor

  for k, v in pairs(s.required_vars) do
    if not is(anchor[k], v) then
      error(
        ("State anchor does not match state interface. ('%s' must be %s)")
          :format(k, v))
    end
  end

  local _ = try(inst.new, inst, ...)

  return inst
end

local function state(required_vars)
  local s = {}
  s.__index = s
  s.create = create
  s.required_vars = required_vars
  return s
end

return state
