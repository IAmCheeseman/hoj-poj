local core = require("core")
local lui = require("ui.lui")
local kg = require("ui.kirigami")
local Slot = require("slot")
local UiSlot = require("ui.slot")
local Sprite = require("sprite")
local items = require("item_init")
local style = require("ui.style")

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
  -- local bg = kg.Region(0, 0, inventoryBg.width, inventoryBg.height):center(r)
  --
  -- love.graphics.setColor(0, 0, 0, 0.33)
  -- inventoryBg:draw(bg.x + 1, bg.y + 3)
  -- love.graphics.setColor(1, 1, 1)
  -- inventoryBg:draw(bg.x, bg.y)
  --
  -- local invw = 4
  -- for i, slot in ipairs(self.slots) do
  --   i = i - 1
  --   local slotx = (i % invw * 16)
  --   slotx = 16 * 3 - slotx + bg.x
  --   local sloty = (math.floor(i / invw) * 16)
  --   sloty = 16 - sloty + bg.y
  --
  --   slot:render(slotx + 5, sloty + 4, 16, 16)
  -- end

  local slotSize = 16
  local padding = 4

  local totalw = (slotSize + padding) * #self.slots
  local slotSpace = kg.Region(0, r.y, totalw, slotSize)
  local slots = slotSpace:fillWith(kg.Region(0, 0, slotSize + padding, slotSize))

  love.graphics.setColor(1, 1, 1)
  for i=#self.slots, 1, -1 do
    local slot = self.slots[i]
    local slotr = slots[i]:padPixels(padding / 2, 0)
    slot:render(slotr:get())
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
