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
  for i=1, opts.count do
    local spread = math.rad(opts.spread * (i/opts.count) - opts.spread * 0.5)
    local angle = opts.angle + spread
    angle = angle + math.rad(mathx.frandom(-opts.accuracy, opts.accuracy))

    local speed = mathx.frandom(opts.speed_min, opts.speed_max)

    opts.speed = speed
    opts.angle = angle

    weapon_util.singleFire(opts)
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
