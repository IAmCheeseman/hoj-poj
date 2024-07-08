local class = require("class")
local mathf = require("mathf")

local Viewport = class()

function Viewport:init(width, height)
  self.width = width
  self.height = height
  self.centered = true
  self.camx = 0
  self.camy = 0
  self.canvas = love.graphics.newCanvas(width + 1, height + 1)
end

function Viewport:m_scaleAndPos()
  local ww, wh = love.graphics.getDimensions()

  local scale = math.min(ww / self.width, wh / self.height)
  local x = (ww - self.width * scale) / 2
  local y = (wh - self.height * scale) / 2
  return scale, x, y
end

function Viewport:getTranslate()
  local camx, camy = -math.floor(self.camx), -math.floor(self.camy)
  if self.centered then
    camx = camx + self.width / 2
    camy = camy + self.height / 2
  end
  return camx, camy
end

function Viewport:mousePos()
  local scale, x, y = self:m_scaleAndPos()
  local camx, camy = self.camx, self.camy
  if self.centered then
    camx = camx - self.width / 2
    camy = camy - self.height / 2
  end
  local mx, my = love.mouse.getPosition()
  mx = mx - x
  my = my - y

  mx = math.floor(camx + mx / scale)
  my = math.floor(camy + my / scale)
  return mx, my
end

function Viewport:setCamPos(x, y)
  self.camx = x
  self.camy = y
end

function Viewport:getCamPos()
  return self.camx, self.camy
end

function Viewport:getSize()
  return self.width, self.height
end

function Viewport:hasRect(x, y, w, h)
  local camx, camy = self:getTranslate()
  camx = -camx
  camy = -camy
  return x < camx + self.width
     and camx < x + w
     and y < camy + self.height
     and camy < y + h
end

function Viewport:hasPoint(x, y)
  return Viewport:hasRect(x, y, 0,0)
end

function Viewport:apply()
  love.graphics.setCanvas(self.canvas)
  love.graphics.push()
  love.graphics.origin()
  local camx, camy = self:getTranslate()
  love.graphics.translate(camx, camy)
end

function Viewport:stop()
  love.graphics.setCanvas()
  love.graphics.pop()
end

function Viewport:draw()
  local scale, x, y = self:m_scaleAndPos()
  local quad = love.graphics.newQuad(
    mathf.frac(self.camx), mathf.frac(self.camy),
    self.width, self.height,
    self.width + 1, self.height + 1)
  love.graphics.draw(self.canvas, quad, x, y, 0, scale)
end

return Viewport
