Effect = struct()

function Effect:new(sprite_path, random_rot)
  self.sprite = Sprite.create(sprite_path):offset("center", "center")
  self.rot = random_rot and love.math.random(mathx.tau) or 0
  self.playback_speed = mathx.frandom(0.9, 1.1)
end

function Effect:step(dt)
  self.sprite:update(dt, self.playback_speed)

  if self.sprite.is_over then
    world.rem(self)
  end
end
