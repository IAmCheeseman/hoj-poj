local class = require("class")

local ImageLayer = class()

function ImageLayer:init(map, dir, data)
  local path, matchCount = data.image:gsub("^%.%.%/", "")
  path = "/" .. path
  if matchCount ~= 0 then
    dir = dir:gsub("%/[^%/]-$", "")
  end
  path = dir .. path

  self.image = love.graphics.newImage(path)
  self.image:setWrap("repeat")
  self.quad = love.graphics.newQuad(
    0, 0,
    map.pxWidth, map.pxHeight,
    self.image:getDimensions())
end

function ImageLayer:draw()
  love.graphics.draw(self.image, self.quad)
end

return ImageLayer
