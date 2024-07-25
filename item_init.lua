local Sprite = require("sprite")

return {
  food = {
    sprite = Sprite("assets/items/food.png"),
    displayName = "items_food",
    maxStack = 16,
  },
  medkit = {
    sprite = Sprite("assets/items/medkit.png"),
    displayName = "items_medkit",
    maxStack = 8,
  }
}
