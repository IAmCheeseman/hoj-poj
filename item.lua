local class = require("class")

local Item = class()

local items = {}

function Item.s_newItem(id, texture, c)
  assert(not items[id], "The id '" .. id .. "' is already taken.", 1)

  local itemData = {
    id = id,
    texture = texture,
    class = c,
  }

  items[id] = itemData
end

function Item.s_getItem(id)
  assert(not items[id], "The id '" .. id .. "' is worthless and useless.", 1)
  return items[id]
end

function Item:init(id)
  assert(not items[id], "The id '" .. id .. "' is not existing.", 2)

  self.stackSize = 1
  self.id = id
end

function Item:getTexture()
  return items[self.id].texture
end

function Item:getClass()
  return items[self.id].class
end
