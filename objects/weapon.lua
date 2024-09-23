local weapons = require("weapons")

Weapon = struct()

function Weapon:new(anchor, data)
  self.tags = {"weapon"}

  self.anchor = anchor

  self.target_offset_x = 0
  self.target_offset_y = -4

  self.slot = data

  self.rot = 0
  self.scaley = 1

  self.reload = 0
  self.released_fire = true

  self.burst = 0
  self.burst_timer = 0
end

function Weapon:reset()
  self.burst = 0
  self.burst_timer = 0
end

function Weapon:step(dt)
  self.x = self.anchor.x + self.target_offset_x
  self.y = self.anchor.y + self.target_offset_y

  local mx, my = getPointerPosition()
  local dirx, diry = vec.direction(self.x, self.y, mx, my)
  self.rot = vec.angle(dirx, diry)

  self.reload = self.reload - dt

  local weapon = self.slot:getWeapon()
  if not weapon then
    return
  end

  local automatic = weapon.automatic
  local can_refire = automatic
  if not can_refire then
    -- This weapon is semiauto
    can_refire = self.released_fire
  end

  if action.isDown("fire")  then
    if can_refire and self.reload <= 0 then
      self:fire()

      if weapon.burst then
        self.burst = weapon.burst - 1 -- Minus 1 because we already shot one
        self.burst_timer = weapon.burst_cooldown
      end

      self.released_fire = false
    end
  else
    self.released_fire = true
  end

  if my < self.anchor.y then
    self.z_index = self.anchor.z_index - 2
  else
    self.z_index = self.anchor.z_index + 2
  end


  self.burst_timer = self.burst_timer - dt
  if self.burst_timer <= 0 and self.burst > 0 then
    self.burst_timer = weapon.burst_cooldown
    self.burst = self.burst - 1

    self:fire()
  end

  -- Update graphics
  self.scaley = mx < self.x and -1 or 1
end

function Weapon:fire()
  local weapon = self.slot:getWeapon()
  local consumption = weapon.consumption or 1

  local ammo_type = ammo[weapon.ammo]

  local has_ammo = ammo_type.amount - consumption >= 0

  if not has_ammo then
    local te = TextEffect:create("Empty!", self.x, self.y, {1, 0, 0})
    world.add(te)
    return
  end

  ammo_type.amount = math.max(ammo_type.amount - consumption, 0)

  local x, y =
    self.x + math.cos(self.rot) * weapon.barrel_length,
    self.y + math.sin(self.rot) * weapon.barrel_length

  sound.play(weapon.shoot_sfx, true)

  local angle = self.rot
  if self.slot.dual_wielding then
    angle = angle + math.rad(mathx.frandom(-20, 20))
  end

  weapon.spawnBullets({
    x = x,
    y = y,
    angle = angle,
    burst = self.burst,
  })

  local reload = weapon.reload
  if self.slot.dual_wielding then
    reload = reload / 2
  end
  self.reload = reload

  if self.anchor.vx and self.anchor.vy then
    local recoilx = math.cos(self.rot) * weapon.recoil
    local recoily = math.sin(self.rot) * weapon.recoil
    self.anchor.vx = self.anchor.vx - recoilx
    self.anchor.vy = self.anchor.vy - recoily
  end
end

function Weapon:draw()
  local weapon = self.slot:getWeapon()
  if not weapon then
    return
  end

  weapon.draw(weapon.sprite, self)
end
