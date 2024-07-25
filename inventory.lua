local class = require("class")
local Event = require("event")
local Slot = require("slot")
local items = require("item_init")

local Inventory = class()

function Inventory:init(slotCount)
  self.slots = {}
  self.maxSlots = slotCount

  self.itemAdded = Event()
  self.itemRemoved = Event()
  self.itemMoved = Event()
end

function Inventory:addItem(itemId, amount, index)
  amount = amount or 1

  local added = 0

  if not index then
    -- Slot of the same item > new slot > failure
    for i=self.maxSlots, 1, -1 do
      local slot = self.slots[i]

      if not slot then
        index = i
      end

      if slot and slot:canAdd(itemId) then
        index = i
        break
      end
    end

    if not index then
      return added
    end
  end

  local maxStack = items[itemId].maxStack

  local slot = self.slots[index]
  if slot then
    if slot.itemId == itemId then
      local maxAdd = maxStack - slot.stackSize
      local add = math.min(amount, maxAdd)

      slot.stackSize = slot.stackSize + add
      added = added + add

      if maxAdd < amount then
        local a = self:addItem(itemId, amount - maxAdd)
        added = added + a
      end

      return added
      -- Take stack size into account
    else
      return added
    end
  else
    local slotAmount = math.min(maxStack, amount)
    self.slots[index] = Slot(itemId, slotAmount)
    added = added + slotAmount

    if slotAmount < amount then
      local a = self:addItem(itemId, amount - maxStack)
      added = added + a
    end
  end

  self.itemAdded:call(itemId, amount, index)

  return added
end

function Inventory:removeItem(itemId, amount, mustRemoveAll)
  mustRemoveAll = mustRemoveAll or false

  local removeFrom = {}
  local left = amount

  for i=1, #self.maxSlots do
    local slot = self.slots[i]
    if slot.itemId == itemId then
      table.insert(removeFrom, {index=i, slot=slot})
      left = left - slot.stackSize
      if left <= 0 then
        break
      end
    end
  end

  if left == amount then
    return false
  end
  if mustRemoveAll and left > 0 then
    return false
  end

  left = amount

  for _, s in ipairs(removeFrom) do
    local slot = s.slot
    local index = s.index

    slot.stackSize = slot.stackSize - left

    if slot.stackSize < 0 then
      left = math.abs(slot.stackSize)
    else
      left = 0
    end

    if slot.stackSize == 0 then
      self.slots[index] = nil
    end
  end

  self.itemRemoved:call(itemId)
  return true
end

return Inventory
