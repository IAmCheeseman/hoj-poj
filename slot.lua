local class = require("class")
local items = require("item_init")

local Slot = class()

function Slot:init(itemId, size)
  self.itemId = itemId
  self.stackSize = size or 1
end

function Slot:canAdd(itemId)
  return self.itemId == itemId and self.stackSize < items[self.itemId].maxStack
end

return Slot
