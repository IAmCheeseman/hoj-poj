local weapons = require("weapons")
local common = require("weapon_common")

defineWeapon("pistol", {
    min_difficulty = math.huge,
    sprite = Sprite.create("assets/pistol.png"):offset("left", "center"),
    name = "weapon_pistol",
    ammo = "bullets",
    shoot_sfx = "pistol",
    reload = 0.2,
    recoil = 0,
    barrel_length = 10,
    automatic = false,
    spawnBullets = function(t)
      common.singleFire({
        ignore_tags = {"player"},
        speed = 400,
        x = t.x,
        y = t.y,
        angle = t.angle + math.rad(mathx.frandom(-5, 5)),
        damage = 6,
        sprite = common.bullet_sprite,
      })
      world.add(MuzzleFlash:create(t.x, t.y, 2, common.muzzle_flash))
      camera.jump(1, t.angle + math.pi, 6)
    end,
    draw = common.drawGun,
})
