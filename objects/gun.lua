local class = require("class")
local Sprite = require("sprite")
local vec = require("vec")

local Gun = class()

function Gun:init(anchor, offsetx, offsety)
  self.anchor = anchor
  self.offsetx = offsetx or 0
  self.offsety = offsety or 0

  self.x = anchor.x + self.offsetx
  self.y = anchor.y + self.offsety

  self.angle = 0
  self.sprite = Sprite("assets/player/gun.png")
  self.sprite:alignedOffset("left", "center")
end

function Gun:update()
  self.x, self.y = self.anchor.x + self.offsetx, self.anchor.y + self.offsety
end

function Gun:draw()
  local ax, ay = math.cos(self.angle), math.sin(self.angle)
  local anchorZ = self.anchor.zIndex or 0
  if vec.dot(0, -1, ax, ay) > 0 then
    self.zIndex = anchorZ - 1
  else
    self.zIndex = anchorZ + 1
  end
  local isLeft = vec.dot(-1, 0, ax, ay) > 0
  local scaley = isLeft and -1 or 1
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y, self.angle, 1, scaley)
end

return Gun
