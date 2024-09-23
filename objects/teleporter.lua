Teleporter = struct()

function Teleporter:new()
  self.open = false
  self.suck_player = false
  self.teleported = false

  self.x = 0
  self.y = 0

  self.sprite = Sprite.create("assets/teleporter.ase")
  self.sprite:offset("center", "center")
  self.sprite.layers["on"].visible = false
end

function Teleporter:step(dt)
  self.open = #world.getTagged("enemy") == 0

  if self.open then
    self.sprite.layers["on"].visible = true

    local player = world.getSingleton("player")
    if player then
      local dist = vec.distanceSq(self.x, self.y, player.x, player.y)
      if not self.suck_player and dist < 8^2 then
        world.remProc(player)
        self.suck_player = true
      end

      if self.suck_player then
        player.x = mathx.dtLerp(player.x, self.x, 30, dt)
        player.y = mathx.dtLerp(player.y, self.y, 30, dt)

        if not self.teleported and dist < 2^2 then
          local beam = TeleportBeam:create()
          beam.x = player.x
          beam.y = player.y
          world.add(beam)
          self.teleported = true
        end
      end
    end
  end
end

