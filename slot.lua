local weapons = require("weapons")

local Slot = {}
Slot.__index = Slot

function Slot.create(weapon, dual)
  dual = dual or false

  local s = setmetatable({}, Slot)
  s.weapon = weapon
  s.dual_wielding = dual
  return s
end

function Slot:getWeaponId()
  return self.weapon
end

function Slot:getWeapon()
  if self:isEmpty() then
    return nil
  end
  return weapons[self.weapon]
end

function Slot:isEmpty()
  return self.weapon == nil
end

return Slot
