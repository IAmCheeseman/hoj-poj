local weapons = require("weapons")
local common = require("weapon_common")

weapons.shotgun = {
  sprite = Sprite.create("assets/shotgun.png"):offset(3, "center"),
  name = "weapon_shotgun",
  ammo = "shells",
  shoot_sfx = "shotgun",
  reload = 0.5,
  recoil = 0,
  barrel_length = 11,
  automatic = false,
  spawnBullets = function(t)
    common.shotgunFire({
      ignore_tags = {"player"},
      count = 7,
      speed_min = 350,
      speed_max = 450,
      x = t.x,
      y = t.y,
      angle = t.angle,
      spread = 45,
      accuracy = 5,
      damage = 4.5,
      bounce = 2,
      bounce_damage_mod = 1.2,
      lifetime = 0.5,
      slow_down = 0.2,
      animate_with_lifetime = true,
      sprite = common.pellet_sprite,
    })
    world.add(MuzzleFlash:create(t.x, t.y, 2, common.muzzle_flash))
    camera.shake(1, 0.05, 5, 8, 8, true)
  end,
  draw = common.drawGun,
}
