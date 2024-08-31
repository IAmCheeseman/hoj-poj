Corpse = struct()

local total_corpses = 0
local corpse_limit = 200
local oldest = nil
local newest = nil

local shadow = Sprite.create("assets/player_shadow.png")
shadow:offset("center", "center")

function Corpse:new(sprite, body, x, y, vx, vy)
  self.sprite = sprite
  self.body = body
  self.vx, self.vy = vx, vy
  self.vz = -50
  self.x, self.y = x, y
  self.height = 0

  self.z_index = -1
end

function Corpse:added()
  total_corpses = total_corpses + 1

  if not oldest then
    oldest = self
    newest = self
  else
    self.last = newest
    if newest then
      newest.next = self
    end

    newest = self
  end

  if total_corpses > corpse_limit then
    world.rem(oldest)
    oldest = oldest.next
    oldest.last = nil
  end
end

function Corpse:removed()
  total_corpses = total_corpses - 1
end

function Corpse:step(dt)
  self.vz = self.vz + 15 * 16 * dt
  if self.height == 0 then
    self.vx = mathx.dtLerp(self.vx, 0, 10, dt)
    self.vy = mathx.dtLerp(self.vy, 0, 10, dt)
  end

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  self.height = math.min(self.height + self.vz * dt, 0)

  local coll = self.body:moveAndCollideWithTags({"env"})

  if coll then
    self.vx, self.vy = vec.reflect(self.vx, self.vy, coll.axisx, coll.axisy)
  end

  self.sprite:update(dt)
  self.sprite.is_playing = not self.sprite:isAtAnimationEnd()

  if self.height == 0 then
    self.draw = world.defaultDraw
  end

  if vec.lenSq(self.vx, self.vy) < 5^2 and not self.sprite.is_playing
      and self.height == 0 then
    -- Stop processing this corpse if it no longer must be
    self.step = false
  end
end

function Corpse:draw()
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y + self.height)
  shadow:draw(self.x, self.y)
end
