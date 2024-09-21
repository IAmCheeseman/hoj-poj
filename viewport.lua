local vp = {
  camx = 0,
  camy = 0,
  pointerx = 0,
  pointery = 0,
  screenw = 240,
  screenh = 180,
}

local canvas = love.graphics.newCanvas(vp.screenw + 1, vp.screenh + 1)
local guic = love.graphics.newCanvas(vp.screenw, vp.screenh)

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

function getMousePosition()
  local scale, x, y = vp.getDrawTranslation()
  local mx, my = love.mouse.getPosition()

  mx = mx - x
  my = my - y

  mx = math.floor(mx / scale)
  my = math.floor(my / scale)

  return mx, my
end

function setPointerPosition(x, y)
  vp.pointerx = x
  vp.pointery = y
end

function getPointerPosition()
  return vp.pointerx, vp.pointery
end

function getScreenPointerPosition()
  local sx = vp.pointerx - vp.camx
  local sy = vp.pointery - vp.camy
  return sx, sy
end

function vp.getDrawTranslation()
  local ww, wh = love.graphics.getDimensions()

  local scale = math.min(ww / vp.screenw, wh / vp.screenh)
  local x = (ww - vp.screenw * scale) / 2
  local y = (wh - vp.screenh * scale) / 2
  return scale, x, y
end

function vp.getCamBounds()
  local x, y = vp.camx, vp.camy
  local w, h = vp.screenw, vp.screenh
  return x, y, w, h
end

function vp.isRectOnScreen(x, y, w, h)
  local camx, camy = -vp.camx, -vp.camy

  -- 1|   2|   1|   2|
  return
        x + w > -camx
    and y + h > -camy
    and -camx + vp.screenw > x
    and -camy + vp.screenh > y
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

function vp.applyGui()
  love.graphics.setCanvas(guic)
  love.graphics.clear(0, 0, 0, 0)
end

function vp.stopGui()
  love.graphics.setCanvas()
end

function vp.draw()
  local scale, x, y = vp.getDrawTranslation()
  local _, fx = math.modf(viewport.camx)
  local _, fy = math.modf(viewport.camy)
  local q = love.graphics.newQuad(
    fx, fy, viewport.screenw, viewport.screenh,
    viewport.screenw + 1, viewport.screenh + 1)
  love.graphics.draw(canvas, q, x, y, 0, scale)
  love.graphics.draw(guic, x, y, 0, scale)
end

return vp
