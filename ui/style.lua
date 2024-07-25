local style = {}

style.outlineCol = {0, 0, 0}
style.bgCol = {0, 0, 0, 0.5}
style.textCol = {1, 1, 1}
style.font = love.graphics.newImageFont(
  "assets/font.png",
  " abcdefghijklmnopqrstuvwxyz0123456789.,:;/\\")

function style.rect(col, fillMode, x, y, w, h)
  love.graphics.setColor(col)
  love.graphics.rectangle(fillMode, x, y, w, h)
end

function style.text(col, align, text, x, y, w, _)
  love.graphics.setColor(col)
  love.graphics.printf(text, x, y, w, align)
end

return style
