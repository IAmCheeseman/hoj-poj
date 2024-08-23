MuzzleFlash = struct()

function MuzzleFlash:new(x, y, lifetime, sprite)
  self.sprite = sprite
  self.x = x
  self.y = y
  self.rot = love.math.random(mathx.tau)
  self.lifetime = lifetime
end

function MuzzleFlash:step()
  self.lifetime = self.lifetime - 1
  if self.lifetime <= 0 then
    world.rem(self)
  end
end
