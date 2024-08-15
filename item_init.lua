local Sprite = require("sprite")

return {
  gun = {
    sprite = Sprite("assets/items/gun.png"),
    hudSprite = Sprite("assets/items/gun_hud.png"),
    displayName = "items_gun",
    description = "items_gun_desc",
    type = "weapon",
    ammo = "shell",
    object = require("objects.gun"),
  },
  pistol = {
    sprite = Sprite("assets/items/pistol.png"),
    hudSprite = Sprite("assets/items/pistol_hud.png"),
    displayName = "items_pistol",
    description = "items_pistol_desc",
    ammo = "bullet",
    type = "weapon",
  },
  medkit = {
    sprite = Sprite("assets/items/medkit.png"),
    displayName = "items_medkit",
    type = "misc",
    uses = 5,
  },
}
