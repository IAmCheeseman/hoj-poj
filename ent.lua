local class = require("class")

local Ent = class()

function Ent:init()
  self.x = 0
  self.y = 0

  self.comps = {}
end

function Ent:addComponent(comp)
  self.comps[comp] = 1
end

function Ent:removeComponent(comp)
  if not self.comps[comp] then
    error("This component is not on the entity!", 1)
  end
  self.comps[comp] = nil
end

function Ent:update(dt)
  for comp, _ in pairs(self.comps) do
    if comp.update then
      comp:update(dt)
    end
  end
end

function Ent:draw()
  for comp, _ in pairs(self.comps) do
    if comp.update then
      comp:draw()
    end
  end
end

return Ent
