local core = require("core")
local lui = require("ui.lui")
local kg = require("ui.kirigami")
local style = require("ui.style")
local items = require("item_init")
local Slot = require("slot")

local SlotUI = lui.Element()

function SlotUI:init(inventory, slotIndex)
  self.inventory = inventory
  self.slotIndex = slotIndex
end

function SlotUI:onMousePress(_, _, button)
  local parent = self:getParent()
  if button == 1 then
    local slot = self.inventory.slots[self.slotIndex]
    self.inventory.slots[self.slotIndex], parent.mouseSlot =
      self.inventory:swapSlotsOrMerge(slot, parent.mouseSlot)
    self.inventory.inventoryUpdated:call(self.inventory)
  elseif button == 2 then
    local slot = self.inventory.slots[self.slotIndex]
    self.inventory.slots[self.slotIndex], parent.mouseSlot =
      self.inventory:moveSingleItemTo(slot, parent.mouseSlot)
    -- TODO: Find a way to remove this call, same for the one above
    self.inventory.inventoryUpdated:call(self.inventory)
  end
end

function SlotUI:onRender(x, y, w, h)
  local isHovered = self:contains(core.guiViewport:mousePos())

  local slotx, sloty, slotw, sloth = x, y, w, h
  if isHovered then
    slotw = w * 1.2
    sloth = h * 1.2
    local diffw = slotw - w
    local diffh = sloth - h
    slotx = x - diffw / 2
    sloty = y - diffh / 2
  end

  local bgCol = {0, 0, 0, 0.5}
  local outlineCol = {0, 0, 0}

  if self.inventory.selectedSlot == self.slotIndex then
    bgCol = {0, 1, 1, 0.5}
    outlineCol = {0, 1, 1}
  end

  love.graphics.setColor(bgCol)
  love.graphics.rectangle("fill", slotx, sloty, slotw, sloth)
  love.graphics.setColor(outlineCol)
  love.graphics.rectangle("line", slotx, sloty, slotw, sloth)

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
