Corpse = struct()

function Corpse:new(sprite, body, x, y, vx, vy)
  self.sprite = sprite
  self.body = body
  self.vx, self.vy = vx, vy
  self.x, self.y = x, y

  self.z_index = -1
end

function Corpse:step()
  self.vx = mathx.lerp(self.vx, 0, 0.1)
  self.vy = mathx.lerp(self.vy, 0, 0.1)

  self.x = self.x + self.vx
  self.y = self.y + self.vy

  local coll = self.body:moveAndCollideWithTags({"env"})

  self.z_index = self.y

  if coll then
    self.vx, self.vy = vec.reflect(self.vx, self.vy, coll.axisx, coll.axisy)
  end
end
