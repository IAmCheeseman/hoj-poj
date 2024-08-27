local ui = require("ui")

TextEffect = struct()

function TextEffect:new(text, x, y, color)
  self.lifetime = 2
  self.text = text
  self.x = x - ui.hud_font:getWidth(self.text) / 2
  self.y = y - ui.hud_font:getHeight()
  self.color = color

  self.z_index = math.huge
end

function TextEffect:step(dt)
  self.lifetime = self.lifetime - dt
  self.y = self.y - 16 * dt

  if self.lifetime <= 0 then
    world.rem(self)
  end
end

function TextEffect:draw()
  love.graphics.setColor(self.color)
  local stepped = mathx.snap(self.lifetime, 0.05) * 20
  if self.lifetime < 0.5 and stepped % 2 == 0 then
    return
  end
  love.graphics.print(self.text, self.x, self.y)
end
