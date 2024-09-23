Teleporter = struct()

function Teleporter:new()
  self.open = false

  self.x = 0
  self.y = 0

  self.sprite = Sprite.create("assets/teleporter.ase")
  self.sprite:offset("center", "center")
  self.sprite.layers["on"].visible = false
end

function Teleporter:step()
  self.open = #world.getTagged("enemy") == 0

  if self.open then
    self.sprite.layers["on"].visible = true

    local player = world.getSingleton("player")
    if player then
      if vec.distanceSq(self.x, self.y, player.x, player.y) < 16^2 then
        Forest:switch({new_run=false})
      end
    end
  end
end

