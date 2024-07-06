local class = require("class")

local ImageLayer = class()

function ImageLayer:init(dir, data)
  local path, matchCount = data.image:gsub("^%.%.%/", "")
  path = "/" .. path
  if matchCount ~= 0 then
    dir = dir:gsub("%/[^%/]-$", "")
  end
  path = dir .. path

  self.image = love.graphics.newImage(path)
end

return ImageLayer
