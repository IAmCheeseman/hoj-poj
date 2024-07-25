local lui = require("ui.lui")
local kg = require("ui.kirigami")

local NinePatch = lui.Element()

function NinePatch:init(image, left, right, top, bottom)
  self.image = image

  self.left = left
  self.right = right or self.left
  self.top = top or self.right
  self.bottom = bottom or self.top
end

function NinePatch:regionToQuad(base, r)
  local iw, ih = self.image:getDimensions()
  local diffx = r.x - (base.x + base.w)
  local diffy = r.y - (base.y + base.h)
  local x = iw + diffx
  local y = ih + diffy
  print(x, y)
  return love.graphics.newQuad(
    x, y,
    r.w, r.h,
    iw, ih)
end

function NinePatch:onRender(x, y, w, h)
  local r = kg.Region(x, y, w, h)
  local sub = r:padPixels(self.left, self.top, self.right, self.bottom)

  local left, right, top, bottom, tl, tr, bl, br = r:ninePatch(sub)

  love.graphics.draw(self.image, self:regionToQuad(r, tl), tl.x, tl.y)
  love.graphics.draw(self.image, self:regionToQuad(r, tr), tr.x, tr.y)
  love.graphics.draw(self.image, self:regionToQuad(r, bl), bl.x, bl.y)
  love.graphics.draw(self.image, self:regionToQuad(r, br), br.x, br.y)
end

return NinePatch
