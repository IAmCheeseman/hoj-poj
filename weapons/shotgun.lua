local weapons = require("weapons")
local common = require("weapon_common")

defineWeapon("shotgun", {
  min_difficulty = 1,
  sprite = Sprite.create("assets/shotgun.png"):offset(3, "center"),
  name = "weapon_shotgun",
  ammo = "shells",
  shoot_sfx = "shotgun",
  reload = 0.65,
  recoil = 0,
  dual_wield = true,
  barrel_length = 11,
  automatic = false,
  spawnBullets = function(t)
    common.shotgunFire(t, {
      ignore_tags = {"player"},
      count = 8,
      speed_min = 200,
      speed_max = 450,
      x = t.x,
      y = t.y,
      angle = t.angle,
      spread = 35,
      accuracy = 5,
      damage = 4.5,
      pierce = true,
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
})
