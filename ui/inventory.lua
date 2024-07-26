local core = require("core")
local lui = require("ui.lui")
local kg = require("ui.kirigami")
local Slot = require("slot")
local UiSlot = require("ui.slot")
local Sprite = require("sprite")
local items = require("item_init")
local style = require("ui.style")
local translations = require("translations")

local Inventory = lui.Element()

local inventoryBg = Sprite("assets/ui/inventory_bg.png")

function Inventory:init(inventory)
  self.inventory = inventory

  self.slots = {}
  for i=1, inventory.maxSlots do
    local slot = UiSlot(inventory, i)
    table.insert(self.slots, slot)
    self:addChild(slot)
  end
end

function Inventory:onRender(x, y, w, h)
  local r = kg.Region(x, y, w, h)

  local slotSize = 16
  local padding = 4

  local totalw = (slotSize + padding) * #self.slots
  local slotSpace = kg.Region(0, r.y, totalw, slotSize)
  local slots = slotSpace:fillWith(kg.Region(0, 0, slotSize + padding, slotSize))

  local hoveredSlot

  love.graphics.setColor(1, 1, 1)
  for i=#self.slots, 1, -1 do
    local slot = self.slots[i]
    local slotr = slots[i]:padPixels(padding / 2, 0)
    slot:render(slotr:get())

    if slot:contains(core.guiViewport:mousePos()) then
      hoveredSlot = self.inventory.slots[slot.slotIndex]
    end
  end

  if hoveredSlot then
    local linePadding = 2

    local totalWidth = 0
    local totalHeight = 0

    local item = items[hoveredSlot.itemId]

    local addSize = function(text)
    totalHeight = totalHeight + style.font:getHeight() + linePadding
    totalWidth = math.max(
        totalWidth,
        style.font:getWidth(translations.translate(text)))
    end

    local doText = function(fn)
      fn(item.displayName)
      if item.description then
        fn(item.description)
      end
    end

    doText(addSize)

    local mx, my = core.guiViewport:mousePos()
    local startx, starty = mx, my - totalHeight

    local tooltipr = kg.Region(startx, starty, totalWidth, totalHeight)
    local screenr = kg.Region(0, 0, core.guiViewport:getSize())
    tooltipr = tooltipr:clampInside(screenr)

    startx = tooltipr.x
    starty = tooltipr.y

    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle(
      "fill",
      startx - 2, starty - 1,
      totalWidth + 4, totalHeight)

    local currenty = starty

    local tooltip = function(text)
      love.graphics.print(translations.translate(text), startx, currenty)
      currenty = currenty + style.font:getHeight() + linePadding
    end

    love.graphics.setColor(1, 1, 1)
    doText(tooltip)
  end

  if self.mouseSlot then
    local mx, my = core.guiViewport:mousePos()
    local itemId = self.mouseSlot.itemId
    local stackSize = self.mouseSlot.stackSize
    local sprite = items[itemId].sprite
    local spritew, spriteh = sprite.width, sprite.height
    sprite:draw(mx, my - spriteh)

    if stackSize > 1 then
      local t = tostring(stackSize)
      love.graphics.setFont(style.font)
      love.graphics.print(
        t,
        mx + spritew - style.font:getWidth(t) + 1,
        my - style.font:getHeight()/1.5)
    end
  end
end

return Inventory
