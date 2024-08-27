local function drawGun(sprite, gun)
  local mx, _ = getWorldMousePosition()
  local scaley = mx < gun.x and -1 or 1

  love.graphics.setColor(1, 1, 1)
  sprite:draw(gun.x, gun.y, gun.rot, 1, scaley)
end

local function singleFire(speed, x, y, angle, damage, sprite)
  local b = BasicBullet:create(x, y, angle, speed, damage, sprite)
  world.add(b)
end

local function shotgunFire(
    count, speed_min, speed_max, x, y, base_angle, spread, accuracy, damage, sprite)
  for i=1, count do
    local angle = base_angle + math.rad(spread * (i/count) - spread * 0.5)
    angle = angle + math.rad(mathx.frandom(-accuracy, accuracy))

    local speed = mathx.frandom(speed_min, speed_max)

    singleFire(speed, x, y, angle, damage, sprite)
  end
end

local bullet_sprite = Sprite.create("assets/bullet.png")
  :offset("center", "center")
local pellet_sprite = Sprite.create("assets/pellet.png")
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
    reload = 5,
    recoil = 2,
    barrel_length = 10,
    automatic = false,
    spawnBullets = function(t)
      singleFire(
        10,
        t.x, t.y,
        t.angle + math.rad(mathx.frandom(-5, 5)),
        10,
        bullet_sprite)
      world.add(MuzzleFlash:create(t.x, t.y, 2, muzzle_flash))
      camera.jump(1, t.angle + math.pi, 5)
    end,
    draw = drawGun,
  },
  shotgun = {
    sprite = Sprite.create("assets/shotgun.png"):offset(3, "center"),
    name = "weapon_shotgun",
    ammo = "shells",
    shoot_sfx = "shotgun",
    reload = 20,
    recoil = 5,
    barrel_length = 11,
    automatic = false,
    spawnBullets = function(t)
      shotgunFire(7, 8, 12, t.x, t.y, t.angle, 45, 5, 7, pellet_sprite)
      world.add(MuzzleFlash:create(t.x, t.y, 2, muzzle_flash))
      camera.shake(1, 2, 5, 3, 6, true)
    end,
    draw = drawGun,
  },
  swiss_rifle = {
    sprite = Sprite.create("assets/swiss_rifle.png"):offset(4, "center"),
    name = "weapon_swiss_rifle",
    ammo = "bullets",
    shoot_sfx = "rifle",
    reload = 3,
    recoil = 1,
    max_burst = 10,
    burst_cooldown = 0.6,
    barrel_length = 10,
    automatic = true,
    spawnBullets = function(t)
      local accuracy = math.min(t.burst^1.5, 30)
      singleFire(
        10,
        t.x, t.y,
        t.angle + math.rad(mathx.frandom(-accuracy, accuracy)),
        11,
        bullet_sprite)
      world.add(MuzzleFlash:create(t.x, t.y, 2, muzzle_flash))
      camera.jump(1, t.angle + math.pi, 4)
    end,
    draw = drawGun,
  },
}
