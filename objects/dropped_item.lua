local core = require("core")
local object = require("object")
local items = require("item_init")
local shadow = require("shadow")
local TiledMap = require("tiled.map")

local DroppedItem = object()

function DroppedItem:init(itemId, shine)
  self.itemId = itemId
  self.shine = shine

  local item = items[itemId]
  self.sprite = item.sprite:copy()
  self.sprite:alignedOffset("center", "center")

  self.velx = 0
  self.vely = 0

  local shape = core.physics.rect(
    -self.sprite.width / 2, -self.sprite.height / 2,
    self.sprite.width, self.sprite.height)
  self.body = core.ResolverBody(self, shape, {
    mask = {"env"},
  })
  core.physics.world:addBody(self.body)

  self.pickup = core.SensorBody(self, shape, {
    mask = {"player"},
  })
  core.physics.world:addBody(self.pickup)

  self.softColl = core.SensorBody(self, shape, {
    layers = {"item"},
    mask = {"item"},
  })
  core.physics.world:addBody(self.softColl)

  self.pickupTimer = 1
end

function DroppedItem:removed()
  core.physics.world:removeBody(self.body)
  core.physics.world:removeBody(self.pickup)
  core.physics.world:removeBody(self.softColl)
end

function DroppedItem:update(dt)
  self.zIndex = self.y

  self.pickupTimer = self.pickupTimer - dt

  if self.pickupTimer <= 0 then
    for _, body in ipairs(self.pickup:getAllColliders()) do
      local anchor = body.anchor
      if anchor.inventory then
        anchor.inventory:addItem(self.itemId)
        core.world:remove(self)
        return
      end
    end
  end

  local pushx, pushy = 0, 0
  for _, body in ipairs(self.softColl:getAllColliders()) do
    local anchor = body.anchor
    local dirx, diry = core.vec.direction(self.x, self.y, anchor.x, anchor.y)
    pushx = pushx - dirx
    pushy = pushy - diry
  end
  pushx, pushy = core.vec.normalize(pushx, pushy)
  local pushStrength = 50
  pushx = pushx * pushStrength
  pushy = pushy * pushStrength

  self.velx = self.velx + pushx * dt
  self.vely = self.vely + pushy * dt

  self.velx = core.math.dtLerp(self.velx, 0, 5)
  self.vely = core.math.dtLerp(self.vely, 0, 5)

  self.velx, self.vely = self.body:moveAndCollide(self.velx, self.vely)

  local time = core.getRuntime()
  local w = (math.sin(time * 3) + 1) / 2
  w = core.math.lerp(self.sprite.width / 4, self.sprite.width / 2, w)
  shadow.queueDraw(w, self.x, self.y + self.sprite.height / 2)

end

function DroppedItem:draw()
  local time = core.getRuntime()
  local x, y = self.x, self.y + math.sin(time * 3) * 2

  if self.shine then
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
  end

  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(x, y)
end

TiledMap.s_addSpawner("FOOD", function(world, data)
  local food = DroppedItem("food", true)
  food.x = data.x
  food.y = data.y
  world:add(food)
end)

return DroppedItem
