PauseScreen = struct()

action.define("pause", "key", "escape")

function PauseScreen:new()
  self.step_while_paused = true
end

function PauseScreen:step()
  if action.isJustDown("pause") then
    world.is_paused = not world.is_paused
  end
end

function PauseScreen:gui()
  if world.is_paused then
    love.graphics.printf("Paused", 0, 50, viewport.screenw, "center")
  end
end
