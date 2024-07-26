local core = require("core")
local object = require("object")
local items = require("item_init")
local shadow = require("shadow")
local TiledMap = require("tiled.map")

local DroppedItem = object()

function DroppedItem:init(itemId)
  self.itemId = itemId

  local item = items[itemId]
  self.sprite = item.sprite:copy()
  self.sprite:alignedOffset("center", "center")

  self.pickup = core.SensorBody(
    self, core.physics.rect(0, 0, self.sprite.width, self.sprite.height), {
    mask = {"player"},
  })
  core.physics.world:addBody(self.pickup)
end

function DroppedItem:update()
  self.zIndex = self.y

  for _, body in ipairs(self.pickup:getAllColliders()) do
    local anchor = body.anchor
    if anchor.inventory then
      anchor.inventory:addItem(self.itemId)
      core.world:remove(self)
      return
    end
  end

  local time = core.getRuntime()
  local w = (math.sin(time * 3) + 1) / 2
  w = core.math.lerp(self.sprite.width / 4, self.sprite.width / 2, w)
  shadow.queueDraw(w, self.x, self.y + self.sprite.height / 2)

end

function DroppedItem:draw()
  local time = core.getRuntime()
  local x, y = self.x, self.y + math.sin(time * 3) * 2
  love.graphics.setBlendMode("add")
	for i=1, 8 do
		local a = .4
		local dist = 8
		local pointOffset = 0.15
		if i % 2 == 0 then
			a = .65
			dist = 12
			pointOffset = 0.2
    end

		local vertices = {x, y}
    local tau = math.pi * 2
    local p = i / 8
    local angle = time + tau * p
    table.insert(vertices, x + math.cos(angle + pointOffset) * dist)
    table.insert(vertices, y + math.sin(angle + pointOffset) * dist)
    table.insert(vertices, x + math.cos(angle - pointOffset) * dist)
    table.insert(vertices, y + math.sin(angle - pointOffset) * dist)

    love.graphics.setColor(0.75, 0.5, 0, a)
    love.graphics.polygon("fill", vertices)
  end

  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(x, y)
end

TiledMap.s_addSpawner("FOOD", function(world, data)
  local food = DroppedItem("food")
  food.x = data.x
  food.y = data.y
  world:add(food)
end)
