local class = require("class")
local log = require("log")

local World = class()

function World:init()
  self.objMeta = {}
  self.addQueue = {}
  self.removeQueue = {}
  self.objs = {}

  self.nextId = 1
end

function World:add(obj)
  table.insert(self.addQueue, obj)
end

function World:remove(obj)
  if not self.objMeta[obj] then
    error("Cannot remove an object which is not in the world.", 1)
    return
  end
  table.insert(self.removeQueue, obj)
end

function World:getObjCount()
  return #self.objs
end

function World:m_flushQueues()
  for _, obj in ipairs(self.addQueue) do
    table.insert(self.objs, obj)
    local meta = {
      index = #self.objs,
      id = self.nextId,
    }
    self.objMeta[obj] = meta
    self.nextId = self.nextId + 1

    if obj.added then
      obj:added(self)
    end
  end
  self.addQueue = {}

  for _, obj in ipairs(self.removeQueue) do
    local meta = self.objMeta[obj]
    if meta ~= nil then
      local last = self.objs[#self.objs]
      self.objMeta[last].index = meta.index

      self.objs[meta.index] = last
      self.objs[#self.objs] = nil

      self.objMeta[obj] = nil

      if obj.removed then
        obj:removed(self)
      end
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
  table.sort(self.objs, function(a, b)
    local az = a.zIndex
    local bz = b.zIndex
    if az == bz then
      az = self.objMeta[a].id
      bz = self.objMeta[b].id
    end
    return az < bz
  end)

  for i, obj in ipairs(self.objs) do
    if type(obj.draw) == "function" then
      obj:draw()
    end
    self.objMeta[obj].index = i
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
