SafehouseLock = struct()

function SafehouseLock:new(x, y)
  self.sprite = Sprite.create("assets/safehouse_lock.ase")
  self.sprite:offset("center", "bottom")

  self.x = x
  self.y = y

  self.z_index = self.y
end

function SafehouseLock:added()
  print(self.x, self.y)
end
