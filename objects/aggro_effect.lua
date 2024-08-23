AggroEffect = struct()

local aggro_spr = Sprite.create("assets/aggro.png")
aggro_spr:offset("center", "center")

function AggroEffect:new(x, y)
  self.lifetime = 40
  self.x = x
  self.y = y
end

function AggroEffect:step()
  self.lifetime = self.lifetime - 1
  self.y = self.y - 0.5

  if self.lifetime <= 0 then
    world.rem(self)
  end
end

function AggroEffect:draw()
  love.graphics.setColor(1, 1, 1)
  if self.lifetime < 20 and self.lifetime % 4 <= 2 then
    love.graphics.setColor(1, 1, 1, 0)
  end
  aggro_spr:draw(self.x, self.y)
end
