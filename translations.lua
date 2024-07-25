local translations = {
  en_US = {
    items_food = "Food",
    items_medkit = "Medkit",
    items_gun = "Gun",
    items_wrench = "Wrench",
    items_poison = "Poison",
    items_battery = "Battery",
    items_nuclear = "Nuclear Waste",
    items_gunpowder = "Gunpowder",
    items_ice = "Ice",
    items_bullet = "Regular Bullet",
    items_shell = "Pellets",
    items_hollow_point = "Hollow Point Bullet",
    items_sniper = "Sniper Bullet",
    items_slug = "Slug",
    items_blinker = "Blinker Fluid",
    tooltip_damage = "DMG",
    tooltip_durability = "DUR",
    tooltip_repair = "FIX"
  },
  en_GB = {
    fallback = "en_US",
    items_food = "Grub",
    items_medkit = "Bandage",
    items_gun = "Fat American",
    items_wrench = "Spanna",
    items_battery = "Ba'ery",
    items_nuclear = "Rubbish",
    items_gunpowder = "Gunpow'er",
    items_ice = "Freezin' Cube",
    items_bullet = "Deadly Penetration Device",
    items_shell = "Many Deadly Penetration Devices",
    items_hollow_point = "Deadlier Penetration Device",
    items_sniper = "Deadly Penetrationier Device",
    items_slug = "Big Deadly Penetration Device",
    items_blinker = "Blinka Fluid",
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
    if tr.fallback then
      return translations.translate(id, tr.fallback)
    end
    return nil
  end
  return tr
end

return translations
