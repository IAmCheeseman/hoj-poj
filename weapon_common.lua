local weapon_util = {}

function weapon_util.drawGun(sprite, gun)
  love.graphics.setColor(1, 1, 1)
  sprite:draw(gun.x, gun.y, gun.rot, 1, gun.scaley)
end

function weapon_util.singleFire(opts)
  local b = BasicBullet:create(opts)
  world.add(b)
end

function weapon_util.shotgunFire(opts)
  local base = opts.angle
  for i=0, opts.count-1 do
    local spread = math.rad((i / (opts.count-1) - 0.5) * opts.spread)
    local angle = base + spread
    angle = angle + math.rad(mathx.frandom(-opts.accuracy, opts.accuracy))

    local speed = mathx.frandom(opts.speed_min, opts.speed_max)

    opts.speed = speed
    opts.angle = angle

    weapon_util.singleFire(opts)
  end
end

function weapon_util.parallelFire(fn, opts)
  local x = opts.x
  local y = opts.y
  local angle = opts.angle
  local movex, movey = vec.rotate(1, 0, angle + math.pi / 2)

  for i=0, opts.parallel_count-1 do
    local p = (i / (opts.parallel_count-1) - 0.5) * 2
    local sep = opts.parallel_sep * p
    opts.x = x + movex * sep
    opts.y = y + movey * sep
    fn(opts)
  end
end

weapon_util.bullet_sprite = Sprite.create("assets/bullet.png")
  :offset("center", "center")
weapon_util.pellet_sprite = Sprite.create("assets/pellet.ase")
  :offset("center", "center")
weapon_util.enemy_bullet_sprite = Sprite.create("assets/enemy_bullet.png")
  :offset("center", "center")

weapon_util.muzzle_flash = Sprite.create("assets/muzzle_flash.png")
  :offset("center", "center")

return weapon_util
