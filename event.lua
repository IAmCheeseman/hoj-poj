local class = require("class")

local Event = class()

function Event:init()
  self.callbacks = {}
  self.connections = {}
end

function Event:on(fn)
  table.insert(self.callbacks, fn)
end

function Event:connect(world, fn, obj)
  table.insert(self.connections, {
    world = world,
    fn = fn,
    obj = obj,
  })
end

function Event:call(...)
  for _, fn in ipairs(self.callbacks) do
    fn(...)
  end

  -- Remove dead objects
  local remq = {}
  for i, c in ipairs(self.connections) do
    if c.world:hasObj(c.obj) then
      c.fn(c.obj, ...)
    else
      table.insert(remq, i)
    end
  end

  for i=#remq, 1, -1 do
    local pos = remq[i]

    local last = self.connections[#self.connections]
    self.connections[pos] = last
    self.connections[#self.connections] = nil
  end
end

return Event
