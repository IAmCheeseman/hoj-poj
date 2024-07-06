local class = require("class")

local World = class()

function World:init()
  self.objMeta = {}
  self.addQueue = {}
  self.removeQueue = {}
  self.objs = {}
end

function World:add(obj)
  table.insert(self.addQueue, obj)
end

function World:remove(obj)
  if not self.objMeta[obj] then
    error("Cannot remove an object which is not in the world.", 1)
  end
  table.insert(self.removeQueue, obj)
end

function World:m_flushQueues()
  for _, obj in ipairs(self.addQueue) do
    table.insert(self.objs, obj)
    local meta = {
      index = #self.objs,
    }
    self.objMeta[obj] = meta

    if obj.added then
      obj:added(self)
    end
  end
  self.addQueue = {}

  for _, obj in ipairs(self.removeQueue) do
    local meta = self.objMeta[obj]

    local new = self.objs[#self.objs]
    self.objMeta[new].index = meta.index

    self.objs[meta.index] = self.objs[#self.objs]
    self.objs[#self.objs] = nil

    if obj.removed then
      obj:removed(self)
    end
  end
  self.removeQueue = {}
end

function World:hasObj(obj)
  return self.objMeta[obj] ~= nil
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
