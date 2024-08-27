local function drawGun(sprite, gun)
  local mx, _ = getWorldMousePosition()
  local scaley = mx < gun.x and -1 or 1

  love.graphics.setColor(1, 1, 1)
  sprite:draw(gun.x, gun.y, gun.rot, 1, scaley)
end

local function singleFire(opts)
  local b = BasicBullet:create(opts)
  world.add(b)
end

local function shotgunFire(opts)
  for i=1, opts.count do
    local spread = math.rad(opts.spread * (i/opts.count) - opts.spread * 0.5)
    local angle = opts.angle + spread
    angle = angle + math.rad(mathx.frandom(-opts.accuracy, opts.accuracy))

    local speed = mathx.frandom(opts.speed_min, opts.speed_max)

    opts.speed = speed
    opts.angle = angle

    singleFire(opts)
  end
end

local bullet_sprite = Sprite.create("assets/bullet.png")
  :offset("center", "center")
local pellet_sprite = Sprite.create("assets/pellet.ase")
  :offset("center", "center")

local muzzle_flash = Sprite.create("assets/muzzle_flash.png")
muzzle_flash:offset("center", "center")

sound.load("pistol", "assets/pistol.wav", 8)
sound.load("shotgun", "assets/shotgun.wav")
sound.load("rifle", "assets/rifle.wav", 10)

return {
  pistol = {
    sprite = Sprite.create("assets/pistol.png"):offset("left", "center"),
    name = "weapon_pistol",
    ammo = "bullets",
    shoot_sfx = "pistol",
    reload = 0.15,
    recoil = 0,
    barrel_length = 10,
    automatic = false,
    spawnBullets = function(t)
      singleFire({
        ignore_tags = {"player"},
        speed = 400,
        x = t.x,
        y = t.y,
        angle = t.angle + math.rad(mathx.frandom(-5, 5)),
        damage = 6,
        sprite = bullet_sprite,
      })
      world.add(MuzzleFlash:create(t.x, t.y, 2, muzzle_flash))
      camera.jump(1, t.angle + math.pi, 3)
    end,
    draw = drawGun,
  },
  shotgun = {
    sprite = Sprite.create("assets/shotgun.png"):offset(3, "center"),
    name = "weapon_shotgun",
    ammo = "shells",
    shoot_sfx = "shotgun",
    reload = 0.6,
    recoil = 0,
    barrel_length = 11,
    automatic = false,
    spawnBullets = function(t)
      shotgunFire({
        ignore_tags = {"player"},
        count = 7,
        speed_min = 350,
        speed_max = 450,
        x = t.x,
        y = t.y,
        angle = t.angle,
        spread = 45,
        accuracy = 5,
        damage = 7,
        bounce = 2,
        bounce_damage_mod = 1.2,
        lifetime = 0.5,
        slow_down = 0.2,
        animate_with_lifetime = true,
        sprite = pellet_sprite,
      })
      world.add(MuzzleFlash:create(t.x, t.y, 2, muzzle_flash))
      camera.shake(1, 0.05, 3, 8, 8, true)
    end,
    draw = drawGun,
  },
  swiss_rifle = {
    sprite = Sprite.create("assets/swiss_rifle.png"):offset(4, "center"),
    name = "weapon_swiss_rifle",
    ammo = "bullets",
    shoot_sfx = "rifle",
    reload = 0.3,
    recoil = 0,
    burst = 3,
    burst_cooldown = 0.05,
    barrel_length = 10,
    automatic = true,
    spawnBullets = function(t)
      singleFire({
        ignore_tags = {"player"},
        speed = 400,
        x = t.x,
        y = t.y,
        angle = t.angle + math.rad(mathx.frandom(-5, 5)),
        damage = 11,
        sprite = bullet_sprite,
      })
      world.add(MuzzleFlash:create(t.x, t.y, 2, muzzle_flash))
      camera.jump(1, t.angle + math.pi, 4)
    end,
    draw = drawGun,
  },
}
