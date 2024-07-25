local core = require("core")
local lui = require("ui.lui")
local kg = require("ui.kirigami")
local style = require("ui.style")
local items = require("item_init")
local Sprite = require("sprite")
local Slot = require("slot")

local SlotUI = lui.Element()

local slotNormal = Sprite("assets/ui/slot.png")
local slotHovered = Sprite("assets/ui/slot_hovered.png")

function SlotUI:init(inventory, slotIndex)
  self.inventory = inventory
  self.slotIndex = slotIndex
end

function SlotUI:onMousePress(_, _, button)
  local parent = self:getParent()
  if button == 1 then
    local slot = self.inventory.slots[self.slotIndex]
    if slot and parent.mouseSlot
    and slot.itemId == parent.mouseSlot.itemId then
      -- Add stack from mouse to stack in inventory
      local maxStack = items[slot.itemId].maxStack
      local add = math.min(maxStack - slot.stackSize, parent.mouseSlot.stackSize)

      slot.stackSize = slot.stackSize + add
      parent.mouseSlot.stackSize = parent.mouseSlot.stackSize - add

      if parent.mouseSlot.stackSize <= 0 then
        parent.mouseSlot = nil
      end
    else
      -- Swap items between mouse slot
      slot, parent.mouseSlot = parent.mouseSlot, slot
      self.inventory.slots[self.slotIndex] = slot
    end
  elseif button == 2 then
    local slot = self.inventory.slots[self.slotIndex]

    if slot and parent.mouseSlot
    and slot.itemId == parent.mouseSlot.itemId then
      -- Adding to mouse slot
      slot.stackSize = slot.stackSize - 1
      parent.mouseSlot.stackSize = parent.mouseSlot.stackSize + 1
    elseif slot and not parent.mouseSlot then
      -- Add to empty mouse slot
      slot.stackSize = slot.stackSize - 1
      parent.mouseSlot = Slot(slot.itemId, 1)
    end

    if slot and slot.stackSize <= 0 then
      self.inventory.slots[self.slotIndex] = nil
    end
  end
end

function SlotUI:onRender(x, y, w, h)
  local isHovered = self:contains(core.guiViewport:mousePos())

  local slotImg = isHovered and slotHovered or slotNormal

  -- love.graphics.draw(slotImg, x, y)
  slotImg:draw(x, y)

  love.graphics.setColor(1, 1, 1)
  local slot = self.inventory.slots[self.slotIndex]

  if slot then
    local item = items[slot.itemId]
    local sprite = item.sprite

    local spriter = kg.Region(0, 0, sprite.width, sprite.height)
    local scale = spriter:getScaleToFit(w, h)

    sprite:draw(x, y, 0, scale)

    if slot.stackSize > 1 then
      local t = tostring(slot.stackSize)
      love.graphics.setFont(style.font)
      love.graphics.print(
        t,
        x + w - style.font:getWidth(t) + 1,
        y + h - style.font:getHeight()/1.5)
    end
  end
end

return SlotUI
