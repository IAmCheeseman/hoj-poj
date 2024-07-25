local core = require("core")
local lui = require("ui.lui")
local kg = require("ui.kirigami")
local style = require("ui.style")
local items = require("item_init")
local Sprite = require("sprite")

local Slot = lui.Element()

local slotNormal = Sprite("assets/ui/slot.png")
local slotHovered = Sprite("assets/ui/slot_hovered.png")

function Slot:init(inventory, slotIndex)
  self.inventory = inventory
  self.slotIndex = slotIndex
end

function Slot:onMousePress(_, _, button)
  if button == 1 then
    local parent = self:getParent()
    local slot = self.inventory.slots[self.slotIndex]
    slot, parent.mouseSlot = parent.mouseSlot, slot
    self.inventory.slots[self.slotIndex] = slot
  end
end

function Slot:onRender(x, y, w, h)
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

return Slot
