local input = require("input")

local setup = {}

function setup.connectEvents(viewport, uiRoot)
  input.mousePressed:on(function(...)
    local mx, my = viewport:mousePos()
    uiRoot:mousepressed(mx, my, ...)
  end)
  input.mouseReleased:on(function(...)
    local mx, my = viewport:mousePos()
    uiRoot:mousereleased(mx, my, ...)
  end)
  input.mouseMoved:on(function(...)
    local mx, my = viewport:mousePos()
    uiRoot:mousemoved(mx, my, ...)
  end)
  input.keyPressed:on(function(...)
    uiRoot:keypressed(...)
  end)
  input.keyReleased:on(function(...)
    uiRoot:keyreleased(...)
  end)
  input.textInput:on(function(...)
    uiRoot:textinput(...)
  end)
  input.mouseWheelMoved:on(function(...)
    uiRoot:wheelmoved(...)
  end)
end

return setup
