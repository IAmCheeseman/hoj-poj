TeleportBeam = struct()

local beam = Sprite.create("assets/teleporting_beam.png")
beam:offset("center", 0)
local height = 100

function TeleportBeam:new()
  self.timer = 0
  self.teleport_time = 0.5
  self.scalex = 0

  -- local player = world.getSingleton("player")
  -- if player then
  --   world.remProc(player)
  -- end
end

function TeleportBeam:step(dt)
  self.timer = self.timer + dt
  local p = self.timer / self.teleport_time
  self.scalex = math.sin(p * math.pi)

  if p >= 0.5 then
    local player = world.getSingleton("player")
    if player then
      world.remDrawProc(player)
    end
  end

  if p >= 1 then
    Forest:switch({new_run=false})
  end

  self.z_index = self.y + 10000
end

function TeleportBeam:draw()
  beam:draw(self.x, self.y - height, 0, self.scalex, height)
end
