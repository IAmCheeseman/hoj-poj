local ui = require("ui")

TextEffect = struct()

function TextEffect:new(text, x, y, color)
  self.lifetime = 40
  self.text = text
  self.x = x - ui.hud_font:getWidth(self.text) / 2
  self.y = y - ui.hud_font:getHeight()
  self.color = color

  self.z_index = math.huge
end

function TextEffect:step()
  self.lifetime = self.lifetime - 1
  self.y = self.y - 0.5

  if self.lifetime <= 0 then
    world.rem(self)
  end
end

function TextEffect:draw()
  love.graphics.setColor(self.color)
  if self.lifetime < 20 and self.lifetime % 4 <= 2 then
    return
  end
  love.graphics.print(self.text, self.x, self.y)
end
