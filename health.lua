local Health = {}
Health.__index = Health

function Health.create(anchor, max, vtable)
  local h = setmetatable({}, Health)

  h.anchor = anchor
  h.dead = false
  h.hp = max
  h.max_hp = max
  h.iframes = 5
  h.last_damage = -math.huge
  h.iframes_prevent_damage = false
  h.vtable = vtable
  h.drop_crates = true

  return h
end

function Health:kill()
  self.dead = true
  try(self.vtable.dead, self.anchor, {damage=0, kbx=0, kby=0})
end

function Health:iFramesActive()
  return total_time - self.last_damage <= self.iframes
end

function Health:dropCrate()
  local crate = AmmoCrate:create()
  crate.x = self.anchor.x
  crate.y = self.anchor.y
  world.add(crate)
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

    if self.drop_crates and love.math.random() < 1/6 then
      self:dropCrate()
    end
  end

  return true
end

return Health
