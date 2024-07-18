local object = require("object")
local core  = require("core")
local physicsStats = require("physics.stats")

local font = love.graphics.newImageFont(
  "assets/font.png",
  " abcdefghijklmnopqrstuvwxyz0123456789.,:;/\\")
core.input.addAction("open_debug_menu", "kb", "f1")

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
  y = self:m_drawText("fps: " .. love.timer.getFPS(), x, y)
  y = self:m_drawText("draw calls: " .. stats.drawcalls, x, y)
  y = self:m_drawText(
    "i: " .. stats.images .. ", c: " .. stats.canvases
    .. ", f: " .. stats.fonts,
    x, y)
  y = self:m_drawText("objects: " .. core.world:getObjCount(), x, y)
  y = self:m_drawText("physics bodies: " .. core.physics.world:getBodyCount(), x, y)
  y = self:m_drawText(("cc: %d, r: %d, rc: %d"):format(
    physicsStats.collisionChecks, physicsStats.resolutions, physicsStats.raycasts),
    x, y)
end

return DebugScreen

