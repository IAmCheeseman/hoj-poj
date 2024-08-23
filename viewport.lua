local vp = {
  camx = 0,
  camy = 0,
  screenw = 240,
  screenh = 180,
}

local canvas = love.graphics.newCanvas(vp.screenw, vp.screenh)

function getWorldMousePosition()
  local scale, x, y = vp.getDrawTranslation()
  local mx, my = love.mouse.getPosition()
  local camx, camy = vp.camx, vp.camy

  mx = mx - x
  my = my - y

  mx = math.floor(camx + mx / scale)
  my = math.floor(camy + my / scale)

  return mx, my
end

function vp.getDrawTranslation()
  local ww, wh = love.graphics.getDimensions()

  local scale = math.min(ww / vp.screenw, wh / vp.screenh)
  local x = (ww - vp.screenw * scale) / 2
  local y = (wh - vp.screenh * scale) / 2
  return scale, x, y
end

function vp.isRectOnScreen(x, y, w, h)
  local camx, camy = -vp.camx, -vp.camy

  return x < camx + vp.screenw
    and camx < x + w
    and y < camy + vp.screenh
    and camy < y + h
end

function vp.isPointOnScreen(x, y)
  return vp.isRectOnScreen(x, y, 0, 0)
end

function vp.apply()
  love.graphics.setCanvas(canvas)
  love.graphics.push()
  love.graphics.translate(-math.floor(vp.camx), -math.floor(vp.camy))
end

function vp.stop()
  love.graphics.pop()
  love.graphics.setCanvas()
end

function vp.draw()
  local scale, x, y = vp.getDrawTranslation()
  love.graphics.draw(canvas, x, y, 0, scale)
end

return vp
