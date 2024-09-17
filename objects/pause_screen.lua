PauseScreen = struct()

action.define("pause", "key", "escape")
action.define("exit", "key", "q")

function PauseScreen:new()
  self.step_while_paused = true
end

function PauseScreen:step()
  if action.isJustDown("pause") then
    world.is_paused = not world.is_paused
  end

  if world.is_paused and action.isJustDown("exit") then
    love.event.quit(0)
  end
end

function PauseScreen:gui()
  if world.is_paused then
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, viewport.screenw, viewport.screenh)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Paused", 0, 50, viewport.screenw, "center")
    love.graphics.printf(
      "Press \"esc\" to unpause.\nPress \"q\" to quit.",
      0, 80, viewport.screenw, "center")
  end
end
