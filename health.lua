local weapons = require("weapons")

local Health = {}
Health.__index = Health

local low_ammo_percentage = 0.2

function Health.create(anchor, max, vtable)
  local h = setmetatable({}, Health)

  h.anchor = anchor
  h.dead = false
  h.hp = max
  h.max_hp = max
  h.iframes = 0.2
  h.last_damage = -math.huge
  h.iframes_prevent_damage = false
  h.vtable = vtable
  h.drop_crates = true

  return h
end

function Health:reset()
  self.dead = false
  self.hp = self.max_hp
  self.last_damage = -math.huge
end

function Health:kill()
  self.dead = true
  try(self.vtable.dead, self.anchor, {damage=0, kbx=0, kby=0})
end

function Health:iFramesActive()
  return total_time - self.last_damage <= self.iframes
end

local function getAmmoPercentage(weapon_id)
  if not weapons[weapon_id] then
    return 1
  end

  local ammo_type = weapons[weapon_id].ammo
  local ammo_dat = ammo[ammo_type]
  return ammo_dat.amount / ammo_dat.max
end

function Health:dropCrate()
  local chance = 1/6
  local give_medkit = false

  if getAmmoPercentage(player_data.hand) < low_ammo_percentage
    or getAmmoPercentage(player_data.offhand) < low_ammo_percentage then
    chance = 1/4
  end

  if player_data.health.hp < player_data.health.max_hp
    and love.math.random() < 1/3 then
    give_medkit = true
  end

  if love.math.random() > chance then
    return
  end

  if give_medkit then
    local medkit = MedKit:create()
    medkit.x = self.anchor.x
    medkit.y = self.anchor.y
    world.add(medkit)
  else
    local crate = AmmoCrate:create()
    crate.x = self.anchor.x
    crate.y = self.anchor.y
    world.add(crate)
  end
end

function Health:heal(amount)
  self.hp = math.min(self.hp + amount, self.max_hp)
end

function Health:takeDamage(attack)
  if self:iFramesActive() and self.iframes_prevent_damage then
    return true
  end

  if self.dead then
    return false
  end

  self.last_damage = total_time
  self.hp = self.hp - attack.damage

  try(self.vtable.damaged, self.anchor, attack)
  if self.hp <= 0 and not self.dead then
    self.dead = true
    try(self.vtable.dead, self.anchor, attack)

    if self.drop_crates then
      self:dropCrate()
    end
  end

  return true
end

return Health
