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

  self.z_index = -math.huge
end

function Background:draw()
  local x, y = viewport.camx, viewport.camy
  x = mathx.snap(x, self.width)
  y = mathx.snap(y, self.height)

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.img, self.q, x, y)
end
