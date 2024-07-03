local input = require("input")

local ui = {}

ui.titlefont = love.graphics.newFont(20)
ui.font = love.graphics.newFont(14)
ui.olcol = {0.75, 0.75, 0.75, 1}
ui.bgcol = {1, 1, 1, 1}
ui.foccol = {1, 0.2, 0.5}
ui.unimpfgcol = {0.75, 0.75, 0.75, 1}
ui.fgcol = {0.3, 0.3, 0.3, 1}
ui.padding = 5
ui.rounding = 5

function ui.circle(col, fill, x, y, w, h)
  love.graphics.setColor(col)
  local r = math.min(w, h) / 2
  local cx, cy = x + w / 2, y + h / 2
  love.graphics.circle(fill, cx, cy, r)
end

function ui.rectangle(col, fill, x, y, w, h)
  love.graphics.setColor(col)
  love.graphics.rectangle(fill, x, y, w, h)
end

function ui.roundRectangle(col, fill, r, x, y, w, h)
  love.graphics.setColor(col)
  love.graphics.rectangle(fill, x, y, w, h, r)
end

function ui.text(col, font, text, align, x, y, w, h)
  love.graphics.setColor(col)
  love.graphics.setFont(font)
  local dy = y + h / 2 - font:getHeight() / 2
  love.graphics.printf(text, x, dy, w, align)
end

input.keyPressed:on(function(key, scancode, isrepeat)
  ui.scene:keypressed(key, scancode, isrepeat)
end)

input.keyReleased:on(function(key, scancode)
  ui.scene:keyreleased(key, scancode)
end)

input.mousePressed:on(function(button, istouch, presses)
  local mx, my = love.mouse.getPosition()
  ui.scene:mousepressed(mx, my, button, istouch, presses)
end)

input.mouseReleased:on(function(button, istouch)
  local mx, my = love.mouse.getPosition()
  ui.scene:mousereleased(mx, my, button, istouch)
end)

input.mouseMoved:on(function(rx, ry, istouch)
  local mx, my = love.mouse.getPosition()
  ui.scene:mousemoved(mx, my, rx, ry, istouch)
end)

input.textInput:on(function(text)
  ui.scene:textinput(text)
end)

input.mouseWheelMoved:on(function(x, y)
  ui.scene:wheelmoved(x, y)
end)

return ui
