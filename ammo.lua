ammo = {}
local ammo_types = {}

function resetAmmo()
  for _, type in pairs(ammo) do
    type.amount = type.starting
  end
end

function defineAmmoType(type, name, starting, max, crate)
  table.insert(ammo_types, type)
  ammo[type] = {
    name = name,
    starting = starting,
    amount = 0,
    crate_amount = crate,
    max = max,
  }
end

function getAmmoTypes()
  return ammo_types
end

defineAmmoType("bullets", "ammo_bullets", 100, 256, 20)
defineAmmoType("shells", "ammo_shells", 24, 64, 12)
