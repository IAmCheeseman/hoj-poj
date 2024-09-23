local weapons = require("weapons")
local ui = require("ui")
local Slot = require("slot")

DroppedWeapon = struct()

function DroppedWeapon:new(type, dual, x, y)
  self.tags = {"dropped_weapon"}

  self.slot = Slot.create(type, dual)

  self.x = x
  self.y = y
  self.rot = love.math.random(mathx.tau)

  self.can_pickup = false

  self.z_index = self.y
end

function DroppedWeapon:draw()
  local weapon = self.slot:getWeapon()
  if not weapon then
    world.rem(self)
    return
  end

  love.graphics.setColor(1, 1, 1)
  weapon.sprite:draw(self.x, self.y, self.rot)

  if self.can_pickup then
    love.graphics.setFont(ui.hud_font)

    local text = ("[e] %s"):format(tr(weapon.name))
    if self.slot.dual_wielding then
      text = text .. " x2"
    end
    local w = ui.hud_font:getWidth(text)
    local y = math.max(weapon.sprite.width, weapon.sprite.height)
    love.graphics.print(text, self.x - w / 2, self.y - y)
  end
end
