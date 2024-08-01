local class = require("class")
local items = require("item_init")
local core = require("core")

local Slot = class()

function Slot:init(itemId, size)
  self.itemId = itemId
  self.stackSize = size or 1
  local item = items[itemId]

  self.lifetime = item.lifetime
  self.durability = item.uses
end

function Slot.s_mergeLifetimes(lt1, lt2, s1, s2)
  local totalItems = s1 + s2
  local nl1 = core.math.lerp(lt1, lt2, s2 / totalItems)
  local nl2 = core.math.lerp(lt2, lt1, s2 / totalItems)
  return nl1, nl2
end

function Slot:drawDurabilityBar(x, y, w, h)
  local item = items[self.itemId]
  local p = 0

  if self.lifetime then
    p = self.lifetime / item.lifetime
  elseif self.durability then
    p = self.durability / item.uses
  end

  if p == 0 then
    return
  end

  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor(0.5, 1, 0.5)
  love.graphics.rectangle("fill", x + 1, y + 1, (w - 2) * p, h - 2)
end

function Slot:updateLifetime()
  if not self.lifetime then
    return false
  end

  local dt = love.timer.getDelta()
  self.lifetime = self.lifetime - dt
  local rotten = self.lifetime <= 0
  if rotten then
    local item = items[self.itemId]
    local rotInto = items[item.rotInto]

    self.itemId = item.rotInto
    self.lifetime = rotInto.lifetime
    self.durability = rotInto.uses
  end

  return rotten
end

function Slot:use(usedIncorrectly)
  if not self.durability then
    return false
  end

  local damage = usedIncorrectly and 2 or 1
  self.durability = self.durability - damage
  return self.durability <= 0
end

function Slot:canAdd(itemId)
  return self.itemId == itemId and self.stackSize < items[self.itemId].maxStack
end

return Slot
