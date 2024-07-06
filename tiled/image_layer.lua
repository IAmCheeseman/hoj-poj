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

  local vpWidth, vpHeight = self.map.viewport:getSize()
  local iWidth, iHeight = self.image:getDimensions()

  self.quadWidth = mathf.snapped(vpWidth, iWidth)
  self.quadHeight = mathf.snapped(vpHeight, iHeight)
  self.quad = love.graphics.newQuad(
    0, 0,
    self.quadWidth * 3, self.quadHeight * 3,
    iWidth, iHeight)
end

function ImageLayer:draw()
  local camx, camy = self.map.viewport:getCamPos()
  camx = mathf.snapped(camx, self.quadWidth) - self.quadWidth
  camy = mathf.snapped(camy, self.quadHeight) - self.quadHeight
  love.graphics.draw(self.image, self.quad, camx, camy)
end

return ImageLayer
