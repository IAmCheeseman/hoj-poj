sound.load("pistol", "assets/pistol.wav", 8)
sound.load("shotgun", "assets/shotgun.wav")
sound.load("rifle", "assets/rifle.wav", 10)

local weapon_names = {}
local weapons = {}

function defineWeapon(name, def)
  weapons[name] = def
  table.insert(weapon_names, name)
end

function getAvailableWeapons()
  local avail = {}
  for _, weapon in ipairs(weapon_names) do
    if weapons[weapon].min_difficulty <= getDifficulty() then
      table.insert(avail, weapon)
    end
  end

  return avail
end

function getRandomWeapon()
  local avail = getAvailableWeapons()
  return avail[love.math.random(1, #avail)]
end

return weapons
