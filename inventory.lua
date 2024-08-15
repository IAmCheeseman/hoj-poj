local class = require("class")
local Event = require("event")
local items = require("item_init")

local ammoTypes = {}

local Inventory = class()

function Inventory.s_addAmmo(name, maxAmmo, pickup, starting)
  ammoTypes[name] = {
    maxAmmo = maxAmmo,
    pickup = pickup,
    starting = starting,
  }
end

function Inventory:init(anchor)
  self.anchor = anchor

  self.currentWeaponIndex = 1
  self.weapons = {}
  self.miscItem = nil

  self.ammo = {}
  for k, v in ipairs(ammoTypes) do
    self.ammo[k] = v.starting
  end

  self.itemAdded = Event()
  self.itemRemoved = Event()
  self.inventoryUpdated = Event()
  self.selectedItemChanged = Event()
  self.usedItem = Event()
end

function Inventory:addWeapon(itemId)
  local swapSlot
  if #self.weapons ~= 2 then -- Inventory is not full, use next slot
    swapSlot = #self.weapons + 1
  else -- Inventory is full, use the current item
    swapSlot = self.currentWeaponIndex
  end

  local oldWeapon = self.weapons[swapSlot]
  self.weapons[swapSlot] = itemId

  if oldWeapon then
    -- Drop on ground
    return
  end
end

function Inventory:refreshCurrentWeapon(world)
  local newItemId = self.weapons[self.currentWeaponIndex]
  local oldWeapon = self.currentWeapon
  local oldItemId = oldWeapon and oldWeapon.itemId or nil

  -- Nothing's changed
  if oldItemId == newItemId then
    return
  end

  -- Remove old weapon
  if oldWeapon then
    world:remove(oldWeapon)
    self.currentWeapon = nil
  end

  self.currentWeapon = nil
  local newItem = items[newItemId]
  if not newItem.object then
    return
  end

  local newWeapon = newItem.object(self.anchor)
  self.currentWeapon = newWeapon
  world:add(newWeapon)
end

function Inventory:switchWeapon(world)
  self.currentWeaponIndex = self.currentWeaponIndex % #self.weapons + 1
  self:refreshCurrentWeapon(world)
end

function Inventory:getCurrentWeapon()
  return self.currentWeapon
end

function Inventory:removeCurrentWeapon(world)
  if self.currentWeapon then
    world:remove(self.currentWeapon)
  end
end

function Inventory:useItem()
  if self.currentWeapon.use then
    self.currentWeapon:use()
  end
end

function Inventory:addItem(itemId)
  local item = items[itemId]
  if item.type == "weapon" then
    self:addWeapon(itemId)
  end
end

return Inventory
