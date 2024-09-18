ammo = {}

function resetAmmo()
  for _, type in pairs(ammo) do
    type.amount = type.starting
  end
end

function defineAmmoType(type, name, starting, max, crate)
  ammo[type] = {
    name = name,
    starting = starting,
    amount = 0,
    crate_amount = crate,
    max = max,
  }
end

defineAmmoType("bullets", "ammo_bullets", 32, 256, 20)
defineAmmoType("shells", "ammo_shells", 24, 64, 12)
