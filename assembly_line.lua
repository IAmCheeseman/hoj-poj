local class = require("class")

local AssemblyLine = class()

function AssemblyLine:init()
  self.steps = {}
end

function AssemblyLine:produce(base)
  local product = base
  for _, step in ipairs(self.steps) do
    if step.obj then
      product = step.func(step.obj, product, unpack(step.args))
    else
      product = step.func(product, unpack(step.args))
    end
  end
  return product
end

function AssemblyLine:addStep(obj, stepFunc, ...)
  local step = {
    func = stepFunc,
    obj = obj,
    args = {...},
  }

  table.insert(self.steps, step)
end

return AssemblyLine
