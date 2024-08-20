local object = require("object")
local Sprite = require("sprite")
local core = require("core")
local Event = require("event")

local Bullet = require("objects.bullet")

local Gun = object()

function Gun:init(anchor, data, offsetx, offsety)
  self.anchor = anchor
  self.offsetx = offsetx or 0
  self.offsety = offsety or 0

  self.data = data

  self.fired = Event()

  self.x = anchor.x + self.offsetx
  self.y = anchor.y + self.offsety

  self.kickback = 0

  self.reload = 0

  self.angle = 0
  self.sprite = Sprite("assets/items/gun.png")
  self.sprite:alignedOffset("left", "center")
  self.sprite.offsetx = 4

  self.canShoot = true
end

function Gun:update(dt)
  self.x, self.y = self.anchor.x + self.offsetx, self.anchor.y + self.offsety

  self.kickback = core.math.dtLerp(self.kickback, 0, 10)

  self.reload = self.reload - dt
end

function Gun:draw()
  local ax, ay = math.cos(self.angle), math.sin(self.angle)
  local anchorZ = self.anchor.zIndex
  if core.vec.dot(0, -1, ax, ay) > 0 then
    self.zIndex = anchorZ - 2
  else
    self.zIndex = anchorZ + 2
  end
  local isLeft = core.vec.dot(-1, 0, ax, ay) > 0
  local scaley = isLeft and -1 or 1
  love.graphics.setColor(1, 1, 1)

  local x = self.x
  local y = self.y

  x = x - math.cos(self.angle) * self.kickback
  x = x - math.cos(self.angle) * 2 -- Align with arm
  y = y - math.sin(self.angle) * self.kickback

  local angle = self.angle - self.kickback * scaley * 0.1

  self.sprite:draw(x, y, angle, 1, scaley)
end

function Gun:use()
  return self:fire()
end

function Gun:fire()
  if self.reload > 0 or not self.canShoot then
    return
  end

  local rot = self.angle
  local speed = 300

  local offset = 8

  self.kickback = 4

  local x, y =
    self.x + math.cos(rot) * offset,
    self.y + math.sin(rot) * offset

  local bullet = Bullet(self.anchor, x, y, rot, speed)
  core.world:add(bullet)

  self.reload = self.data.reloadTime

  self.fired:call(bullet)
end

return Gun
