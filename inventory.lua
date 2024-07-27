local class = require("class")
local Event = require("event")
local Slot = require("slot")
local items = require("item_init")
local core = require("core")

local Inventory = class()

local function onInventoryChanged(inventory)
  -- when inventory updated, update held item
  inventory:updateHeldItem()
end

function Inventory:init(anchor, slotCount)
  self.anchor = anchor

  self.slots = {}
  self.maxSlots = slotCount

  self.itemAdded = Event()
  self.itemRemoved = Event()
  self.inventoryUpdated = Event()
  self.selectedItemChanged = Event()
  self.usedItem = Event()

  self.inventoryUpdated:on(onInventoryChanged)

  self:setSelectedSlot(1)
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

  self.itemAdded:call(self, itemId, amount, index)
  self.inventoryUpdated:call(self)

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

  self.itemRemoved:call(self, itemId)
  self.inventoryUpdated:call(self)

  return true
end

function Inventory:updateHeldItem()
  local slot = self.slots[self.selectedSlot]

  if slot and not self.heldItem then
    local item = items[slot.itemId]
    if item.object then
      self.heldItem = item.object(self.anchor)
      self.heldItem.itemId = slot.itemId
      core.world:add(self.heldItem)
    end
    return
  end

  local itemsMatch = false
  if slot then
    itemsMatch = slot.itemId == self.heldItem.itemId
  end

  if self.heldItem and core.world:hasObj(self.heldItem) and not itemsMatch then
    core.world:remove(self.heldItem)
    self.heldItem = nil
  end
end

function Inventory:swapSlotsOrMerge(slot1Index, slot1, slot2)
  if slot1 and slot2
  and slot1.itemId == slot2.itemId then
    -- We can merge
    local maxStack = items[slot1.itemId].maxStack
    local add = math.min(maxStack - slot1.stackSize, slot2.stackSize)

    slot1.stackSize = slot1.stackSize + add
    slot2.stackSize = slot2.stackSize - add

    if slot2.stackSize <= 0 then
      slot2 = nil
    end
  else
    -- We can't merge; swap instead
    slot1, slot2 = slot2, slot1
    self.slots[slot1Index] = slot1
  end

  self.inventoryUpdated:call(self)
  return slot1, slot2
end

function Inventory:moveSingleItemTo(from, to)
  if from and to
  and from.itemId == to.itemId then
    -- Adding to mouse slot
    from.stackSize = from.stackSize - 1
    to.stackSize = to.stackSize + 1

    self.inventoryUpdated:call(self)
  elseif from and not to then
    -- Add to empty mouse slot
    from.stackSize = from.stackSize - 1
    to = Slot(from.itemId, 1)

    self.inventoryUpdated:call(self)
  end

  if from and from.stackSize <= 0 then
    self.slots[self.slotIndex] = nil
  end
end

function Inventory:setSelectedSlot(selected)
  if self.heldItem then
    core.world:remove(self.heldItem)
    self.heldItem = nil
  end

  self.selectedSlot = selected
  local slot = self.slots[selected]
  self.selectedItemChanged:call(slot)

  self:updateHeldItem()
end

function Inventory:getHeldItem()
  return self.heldItem
end

function Inventory:removeHeldItem()
  if self.heldItem then
    core.world:remove(self.heldItem)
  end
end

function Inventory:useItem(...)
  if not self.heldItem or type(self.heldItem.use) ~= "function" then
    return false
  end
  local res = {self.heldItem:use(...)}
  local slot = self.slots[self.selectedSlot]
  self.usedItem:call(slot.itemId, unpack(res))
  return true, unpack(res)
end

return Inventory
