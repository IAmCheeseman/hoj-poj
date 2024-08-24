local ui = require("ui")

ScoreEffect = struct()

function ScoreEffect:new(score, x, y)
  self.lifetime = 40
  self.score = "+" .. tostring(score)
  self.x = x - ui.hud_font:getWidth(self.score) / 2
  self.y = y - ui.hud_font:getHeight()

  self.z_index = math.huge
end

function ScoreEffect:step()
  self.lifetime = self.lifetime - 1
  self.y = self.y - 0.5

  if self.lifetime <= 0 then
    world.rem(self)
  end
end

function ScoreEffect:draw()
  love.graphics.setColor(1, 1, 0)
  if self.lifetime < 20 and self.lifetime % 4 <= 2 then
    love.graphics.setColor(1, 1, 1, 0)
  end
  love.graphics.print(self.score, self.x, self.y)
end
