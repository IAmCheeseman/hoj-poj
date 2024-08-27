local weapons = require("weapons")

Weapon = struct()

function Weapon:new(anchor, type)
  self.anchor = anchor

  self.target_offset_x = 0
  self.target_offset_y = -4

  self.type = type

  self.reload = 10
  self.released_fire = true

  self.burst = 0
end

function Weapon:reset()
  self.burst = 0
end

function Weapon:step()
  self.x = self.anchor.x + self.target_offset_x
  self.y = self.anchor.y + self.target_offset_y

  local mx, my = getWorldMousePosition()
  local dirx, diry = vec.direction(self.x, self.y, mx, my)
  self.rot = vec.angle(dirx, diry)

  self.reload = self.reload - 1

  local weapon = weapons[self.type]

  local automatic = weapon.automatic
  local can_refire = automatic
  if not can_refire then
    -- This weapon is semiauto
    can_refire = self.released_fire
  end

  if action.isDown("fire")  then
    if can_refire then
      self:fire()
      self.burst = math.min(self.burst + 1, weapon.max_burst or 0)
    end
    self.released_fire = false
  else
    self.released_fire = true
    self.burst = math.max(self.burst - (weapon.burst_cooldown or 1), 0)
  end

  if my < self.anchor.y then
    self.z_index = self.anchor.z_index - 2
  else
    self.z_index = self.anchor.z_index + 2
  end
end

function Weapon:fire()
  local weapon = weapons[self.type]
  local consumption = weapon.consumption or 1

  local ammo_type = ammo[weapon.ammo]

  local reloaded = self.reload <= 0
  local has_ammo = ammo_type.amount - consumption >= 0
  local can_shoot = reloaded and has_ammo

  if not can_shoot then
    return
  end

  ammo_type.amount = math.max(ammo_type.amount - consumption, 0)

  local x, y =
    self.x + math.cos(self.rot) * weapon.barrel_length,
    self.y + math.sin(self.rot) * weapon.barrel_length

  sound.play(weapon.shoot_sfx)

  weapon.spawnBullets({
    x = x,
    y = y,
    angle = self.rot,
    burst = self.burst,
  })
  self.reload = weapon.reload

  if self.anchor.vx and self.anchor.vy then
    local recoilx = math.cos(self.rot) * weapon.recoil
    local recoily = math.sin(self.rot) * weapon.recoil
    self.anchor.vx = self.anchor.vx - recoilx
    self.anchor.vy = self.anchor.vy - recoily
  end
end

function Weapon:draw()
  local weapon = weapons[self.type]
  weapon.draw(weapon.sprite, self)
end
