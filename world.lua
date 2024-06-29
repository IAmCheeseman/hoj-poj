local class = require("class")

local World = class()

function World:init()
  self.objmeta = {}
  self.addq = {}
  self.remq = {}
  self.objs = {}
end

function World:add(obj)
  table.insert(self.addq, obj)
end

function World:remove(obj)
  if not self.objmeta[obj] then
    error("Cannot remove an object which is not in the world.", 1)
  end
  table.insert(self.remq, obj)
end

function World:m_flushQueues()
  for _, obj in ipairs(self.addq) do
    table.insert(self.objs, obj)
    local meta = {
      index = #self.objs,
    }
    self.objmeta[obj] = meta

    if obj.added then
      obj:added(self)
    end
  end
  self.addq = {}

  for _, obj in ipairs(self.remq) do
    local meta = self.objmeta[obj]

    local new = self.objs[#self.objs]
    self.objmeta[new].index = meta.index

    self.objs[meta.index] = self.objs[#self.objs]
    self.objs[#self.objs] = nil

    if obj.removed then
      obj:removed(self)
    end
  end
  self.remq = {}
end

function World:hasObj(obj)
  return self.objmeta[obj] ~= nil
end

function World:update()
  self:m_flushQueues()

  local dt = love.timer.getDelta()
  for _, obj in ipairs(self.objs) do
    if type(obj.update) == "function" then
      obj:update(dt)
    end
  end
end

function World:draw()
  for _, obj in ipairs(self.objs) do
    if type(obj.draw) == "function" then
      obj:draw()
    end
  end
end

function World:drawGui()
  for _, obj in ipairs(self.objs) do
    if type(obj.gui) == "function" then
      obj:gui()
    end
  end
end

return World
