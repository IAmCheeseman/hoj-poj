local weapon_util = {}

weapon_util.dual_accuracy_mod = 2

function weapon_util.drawGun(sprite, gun)
  love.graphics.setColor(1, 1, 1)

  if gun.slot.dual_wielding then
    local movex, movey = vec.rotate(1, 0, gun.rot + math.pi / 2)
    sprite:draw(gun.x - movex * 4, gun.y - movey * 4, gun.rot, 1, -1)
    sprite:draw(gun.x + movex * 4, gun.y + movey * 4, gun.rot, 1, 1)
  else
    sprite:draw(gun.x, gun.y, gun.rot, 1, gun.scaley)
  end
end

function weapon_util.singleFire(t, opts)
  local b = BasicBullet:create(t, opts)
  world.add(b)
end

function weapon_util.shotgunFire(t, opts)
  local base = opts.angle
  for i=0, opts.count-1 do
    local spread = math.rad((i / (opts.count-1) - 0.5) * opts.spread)
    if t.dual_wielding then
      spread = spread * weapon_util.dual_accuracy_mod
    end
    local angle = base + spread
    local speed = mathx.frandom(opts.speed_min, opts.speed_max)

    opts.speed = speed
    opts.angle = angle

    weapon_util.singleFire(t, opts)
  end
end

function weapon_util.parallelFire(t, fn, opts)
  local x = opts.x
  local y = opts.y
  local angle = opts.angle
  local movex, movey = vec.rotate(1, 0, angle + math.pi / 2)

  for i=0, opts.parallel_count-1 do
    local p = (i / (opts.parallel_count-1) - 0.5) * 2
    local sep = opts.parallel_sep * p
    opts.x = x + movex * sep
    opts.y = y + movey * sep
    fn(t, opts)
  end
end

weapon_util.bullet_sprite = Sprite.create("assets/bullet.png")
  :offset("center", "center")
weapon_util.pellet_sprite = Sprite.create("assets/pellet.ase")
  :offset("center", "center")
weapon_util.enemy_bullet_sprite = Sprite.create("assets/enemy_bullet.png")
  :offset("center", "center")
weapon_util.enemy_pellet_sprite = Sprite.create("assets/enemy_pellet.ase")
  :offset("center", "center")

weapon_util.muzzle_flash = Sprite.create("assets/muzzle_flash.png")
  :offset("center", "center")

return weapon_util
