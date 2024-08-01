local translations = {
  en_US = {
    items_food = "food",
    items_food_desc = "non-gmo, gluten free, and carb free.",
    items_medkit = "medkit",
    items_gun = "gun",
    items_gun_desc = "pew pew pew!",
    items_wrench = "wrench",
    items_poison = "poison",
    items_battery = "battery",
    items_nuclear = "nuclear waste",
    items_gunpowder = "gunpowder",
    items_ice = "ice",
    items_bullet = "regular bullet",
    items_shell = "pellets",
    items_hollow_point = "hollow point bullet",
    items_sniper = "sniper bullet",
    items_slug = "slug",
    items_blinker = "blinker fluid",
    items_blinker_desc = "fixes all problems with your car and more!",
    tooltip_damage = "dmg",
    tooltip_durability = "dur",
    tooltip_repair = "fix"
  },
  en_GB = {
    fallback = "en_US",
    items_food = "grub",
    items_medkit = "bandage",
    items_gun = "fat american",
    items_wrench = "spanna",
    items_battery = "ba'ery",
    items_nuclear = "rubbish",
    items_gunpowder = "gunpow'er",
    items_ice = "freezin' cube",
    items_bullet = "deadly penetration device",
    items_shell = "many deadly penetration devices",
    items_hollow_point = "deadlier penetration device",
    items_sniper = "deadly penetrationier device",
    items_slug = "big deadly penetration device",
    items_blinker = "blinka fluid",
  }
}

local currentLocale = "en_US"

function translations.setLocale(id)
  currentLocale = id
end

function translations.translate(id, localeName)
  localeName = localeName or currentLocale

  local locale = translations[localeName]
  if not locale then
    return id
  end

  local tr = locale[id]
  if not tr then
    if locale.fallback then
      return translations.translate(id, locale.fallback)
    end
    return id
  end
  return tr
end

return translations
