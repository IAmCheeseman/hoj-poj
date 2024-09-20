local weapons = require("weapons")
local common = require("weapon_common")

defineWeapon("swiss_rifle", {
    min_difficulty = 1,
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
      common.singleFire({
        ignore_tags = {"player"},
        speed = 400,
        x = t.x,
        y = t.y,
        angle = t.angle + math.rad(mathx.frandom(-5, 5)),
        damage = 11,
        sprite = common.bullet_sprite,
      })
      world.add(MuzzleFlash:create(t.x, t.y, 2, common.muzzle_flash))
      camera.jump(1, t.angle + math.pi, 4)
    end,
    draw = common.drawGun,
})
