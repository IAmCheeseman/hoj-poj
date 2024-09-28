local weapons = require("weapons")
local common = require("weapon_common")

defineWeapon("machinegun", {
    min_difficulty = 3,
    sprite = Sprite.create("assets/machinegun.png"):offset(6, "center"),
    name = "weapon_machinegun",
    ammo = "bullets",
    shoot_sfx = "pistol",
    reload = 0.15,
    recoil = 0,
    barrel_length = 10,
    automatic = true,
    spawnBullets = function(t)
      common.singleFire(t, {
        ignore_tags = {"player"},
        speed = 400,
        x = t.x,
        y = t.y,
        angle = t.angle,
        accuracy = 7,
        damage = 6,
        sprite = common.bullet_sprite,
      })
      world.add(MuzzleFlash:create(t.x, t.y, 2, common.muzzle_flash))
      camera.jump(1, t.angle + math.pi, 6)
    end,
    draw = common.drawGun,
})
