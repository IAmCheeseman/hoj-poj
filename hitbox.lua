local class = require("class")
local core = require("core")
local Event = require("event")

local Hitbox = class()

function Hitbox:init(anchor, damageFunc, sensor)
  self.anchor = anchor
  self.source = anchor

  self.getDamage = damageFunc

  self.sensor = sensor

  self.damaged = Event()
  self.hitEnv = Event()
  self.hitSomething = Event()

  core.pWorld:addBody(sensor)
end

function Hitbox:removed()
  core.pWorld:removeBody(self.sensor)
end

function Hitbox:update()
  local colliders = self.sensor:getAllColliders()
  for _, collider in ipairs(colliders) do
    if collider.anchor.health and collider:isInGroup("hurtbox") then
      local damage = self.getDamage(self.anchor)

      local dirx, diry = self.dirx, self.diry
      if not dirx or not diry then
        dirx, diry = core.vec.direction(
          self.anchor.x, self.anchor.y,
          collider.anchor.x, collider.anchor.y)
      end

      local kbStrength = 150
      local kbx, kby = dirx * kbStrength, diry * kbStrength
      collider.anchor.health:takeDamage(self.source, damage, kbx, kby)
      self.damaged:call(collider.anchor, damage, kbx, kby)
    elseif collider.type == "resolver" then
      self.hitEnv:call()
    end

    self.hitSomething:call()
  end
end

return Hitbox
