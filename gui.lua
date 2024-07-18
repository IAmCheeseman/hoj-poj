local gui = {}

function gui.drawBar(x, y, w, h, p, bg, fg)
  local fillw, fillh = (w - 1) * p, h - 1

  love.graphics.setColor(bg)
  love.graphics.rectangle("fill", x, y, w, h)
  love.graphics.setColor(fg)
  love.graphics.rectangle("fill", x, y, fillw, fillh)
end

return gui
