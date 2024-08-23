Background = struct()

function Background:new(path)
  self.img = love.graphics.newImage(path)
  self.img:setWrap("repeat")

  self.width = mathx.snap(viewport.screenw, self.img:getWidth())
  self.height = mathx.snap(viewport.screenh, self.img:getHeight())
  self.q = love.graphics.newQuad(
    0, 0,
    self.width * 3, self.height * 3,
    self.img:getDimensions())
end

function Background:draw()
  local x, y = viewport.camx, viewport.camy
  x = mathx.snap(x, self.width)
  y = mathx.snap(y, self.height)

  self.z_index = y

  love.graphics.draw(self.img, self.q, x, y)
end
