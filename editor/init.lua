local camera = require("editor.camera")
local ui = require("editor.ui")
local Menu = require("editor.menu")

ui.scene = Menu()
ui.scene:makeRoot()

local editor = {}

function editor.load()
  love.window.setTitle("Xander's Level Editor")
  -- local w, h = 320 * 3, 180 * 3
  -- love.window.updateMode(w, h, {
  --   minwidth = w,
  --   minheight = h,
  -- })
end

function editor.update()
  camera.update()
end

function editor.draw()
  camera.apply()

  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.line(camera.x - camera.w, 0, camera.x + camera.w, 0)
  love.graphics.line(0, camera.y - camera.h, 0, camera.y + camera.h)

  love.graphics.origin()
  ui.scene:render(0, 0, camera.w, camera.h)

  local stats = love.graphics.getStats()
  love.graphics.setColor(0, 0, 1)
  love.graphics.print(stats.drawcalls, 0, 0)
end

return editor
