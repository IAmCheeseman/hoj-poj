local weapons = require("weapons")
local common = require("weapon_common")

defineWeapon("triple_machinegun", {
    min_difficulty = 5,
    sprite = Sprite.create("assets/triple_machinegun.png"):offset(6, "center"),
    name = "weapon_triple_machinegun",
    ammo = "bullets",
    shoot_sfx = "pistol",
    reload = 0.15,
    recoil = 0,
    consumption = 3,
    barrel_length = 10,
    automatic = true,
    spawnBullets = function(t)
      common.parallelFire(common.singleFire, {
        ignore_tags = {"player"},
        speed = 400,
        x = t.x,
        y = t.y,
        angle = t.angle + math.rad(mathx.frandom(-5, 5)),
        damage = 6,
        sprite = common.bullet_sprite,
        parallel_count = 3,
        parallel_sep = 5,
      })
      world.add(MuzzleFlash:create(t.x, t.y, 2, common.muzzle_flash))
      camera.jump(1, t.angle + math.pi, 6)
    end,
    draw = common.drawGun,
})
