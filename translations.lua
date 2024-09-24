local translations = {
  en = {
    weapon_pistol = "Pistol",
    weapon_shotgun = "Shotgun",
    weapon_swiss_rifle = "Swiss Rifle",
    weapon_machinegun = "Machinegun",
    weapon_triple_machinegun = "Triple Machinegun",
    ammo_bullets = "Bullets",
    ammo_shells = "Shells",
  }
}

local locale = "en"

for _, pref in ipairs(love.system.getPreferredLocales()) do
  local l = pref:sub(1, 2)
  if translations[l] then
    locale = l
    log.info("Set locale to " .. l)
    break
  end
end

function setLocale(new_locale)
  locale = new_locale
end

function tr(id)
  local lang = translations[locale]

  if not lang then
    return id
  end

  local translation = lang[id]
  if not translation then
    return id
  end

  return translation
end
