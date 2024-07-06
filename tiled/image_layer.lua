local class = require("class")
local mathf = require("mathf")

local ImageLayer = class()

function ImageLayer:init(map, dir, data)
  local path, matchCount = data.image:gsub("^%.%.%/", "")
  path = "/" .. path
  if matchCount ~= 0 then
    dir = dir:gsub("%/[^%/]-$", "")
  end
  path = dir .. path

  self.map = map
  self.image = love.graphics.newImage(path)
  self.image:setWrap("repeat")

  self.offsetx = data.offsetx
  self.offsety = data.offsety

  self.repeatx = data.repeatx
  self.repeaty = data.repeaty

  local vpWidth, vpHeight = self.map.viewport:getSize()
  local iWidth, iHeight = self.image:getDimensions()

  self.quadWidth = mathf.snapped(vpWidth, iWidth)
  self.quadHeight = mathf.snapped(vpHeight, iHeight)

  local drawWidth = self.repeatx and self.quadWidth * 3 or iWidth
  local drawHeight = self.repeaty and self.quadHeight * 3 or iHeight
  self.quad = love.graphics.newQuad(
    0, 0,
    drawWidth, drawHeight,
    iWidth, iHeight)
end

function ImageLayer:draw()
  local camx, camy = self.map.viewport:getCamPos()
  if self.repeatx then
    camx = mathf.snapped(camx, self.quadWidth) - self.quadWidth
  else
    camx = 0
  end
  if self.repeaty then
    camy = mathf.snapped(camy, self.quadHeight) - self.quadHeight
  else
    camy = 0
  end

  love.graphics.draw(
    self.image,
    self.quad,
    camx + self.offsetx,
    camy + self.offsety)
end

return ImageLayer
