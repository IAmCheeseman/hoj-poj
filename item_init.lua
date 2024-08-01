local Sprite = require("sprite")

return {
  food = {
    sprite = Sprite("assets/items/food.png"),
    displayName = "items_food",
    description = "items_food_desc",
    maxStack = 8,
    lifetime = 20,
    rotInto = "rot",
  },
  rot = {
    sprite = Sprite("assets/items/poison.png"),
    displayName = "rot",
    description = "old organic substances",
    maxStack = 16,
  },
  medkit = {
    sprite = Sprite("assets/items/medkit.png"),
    displayName = "items_medkit",
    maxStack = 3,
  },
  gun = {
    sprite = Sprite("assets/items/gun.png"),
    displayName = "items_gun",
    description = "items_gun_desc",
    object = require("objects.gun"),
    maxStack = 1,
    uses = 75,
  },
  wrench = {
    sprite = Sprite("assets/items/wrench.png"),
    displayName = "items_wrench",
    maxStack = 1,
    uses = 50,
  },
  poison = {
    sprite = Sprite("assets/items/poison.png"),
    displayName = "items_poison",
    maxStack = 20,
  },
  battery = {
    sprite = Sprite("assets/items/battery.png"),
    displayName = "items_battery",
    maxStack = 20,
  },
  nuclear_waste = {
    sprite = Sprite("assets/items/nuclear_waste.png"),
    displayName = "items_nuclear",
    maxStack = 20,
  },
  gunpowder = {
    sprite = Sprite("assets/items/gunpowder.png"),
    displayName = "items_gunpowder",
    maxStack = 20,
  },
  ice = {
    sprite = Sprite("assets/items/ice.png"),
    displayName = "items_ice",
    maxStack = 20,
  },
  bullet = {
    sprite = Sprite("assets/items/regular_bullet.png"),
    displayName = "items_bullet",
    maxStack = 40,
  },
  shell = {
    sprite = Sprite("assets/items/pellets.png"),
    displayName = "items_shell",
    maxStack = 30,
  },
  hollow_point = {
    sprite = Sprite("assets/items/hollow_point.png"),
    displayName = "items_hollow_point",
    maxStack = 30,
  },
  sniper = {
    sprite = Sprite("assets/items/sniper.png"),
    displayName = "items_sniper",
    maxStack = 25,
  },
  slug = {
    sprite = Sprite("assets/items/slug.png"),
    displayName = "items_slug",
    maxStack = 20,
  },
  blinker_fluid = {
    sprite = Sprite("assets/items/blinker_fluid.png"),
    displayName = "items_blinker",
    description = "items_blinker_desc",
    maxStack = 1,
  },
}
