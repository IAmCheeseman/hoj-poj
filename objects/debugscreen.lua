local object = require("object")
local core  = require("core")

core.input.addAction("open_debug_menu", "kb", "f1")

local font = love.graphics.newFont(24)

local DebugScreen = object()

function DebugScreen:init()
  self.visible = false
end

function DebugScreen:added(world)
  core.input.actionTriggered:connect(world, self.m_onActionDown, self)
end

function DebugScreen:m_onActionDown(action, _, isrepeat)
  if action == "open_debug_menu" and not isrepeat then
    self.visible = not self.visible
  end
end

function DebugScreen:m_drawText(text, x, y)
  local width = font:getWidth(text)
  local height = font:getHeight()

  local padding = 4

  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle("fill", x - padding / 2, y, width + padding, height)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(text, x, y)

  return y + height
end

function DebugScreen:gui()
  if not self.visible then
    return
  end

  local x, y = 5, 5
  love.graphics.setFont(font)

  local stats = love.graphics.getStats()
  local rName, rVersion, _, rDevice = love.graphics.getRendererInfo()
  y = self:m_drawText(love.system.getOS(), x, y)
  y = self:m_drawText(rName .. " " .. rVersion, x, y)
  y = self:m_drawText(rDevice, x, y)
  y = self:m_drawText("FPS: " .. love.timer.getFPS(), x, y)
  y = self:m_drawText("Draw calls: " .. stats.drawcalls, x, y)
  y = self:m_drawText(
    "I: " .. stats.images .. ", C: " .. stats.canvases
    .. ", F: " .. stats.fonts,
    x, y)
end

return DebugScreen

