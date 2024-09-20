local translations = {
  en = {
    weapon_pistol = "Pistol",
    weapon_shotgun = "Shotgun",
    weapon_swiss_rifle = "Swiss Rifle",
    ammo_bullets = "Bullets",
    ammo_shells = "Shells",
  }
}

local locale = "en"

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
