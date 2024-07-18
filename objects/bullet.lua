local object = require("object")
local shadow = require("shadow")
local core = require("core")

local Bullet = object()

function Bullet:init(x, y, rot, speed)
  self.x = x
  self.y = y
  self.rot = rot
  self.speed = speed

  self.damage = 5
  self.critChance = 0.2
  self.critMod = 1.3

  self.lifetime = 5

  self.hitbox = core.SensorBody(self, core.physics.rect(-2, -2, 4, 4), {
    offsetx = "center",
    offsety = "center",

    layers = {"bullet"},
    mask = {"env", "enemy"}
  })
  core.physics.world:addBody(self.hitbox)
end

function Bullet:removed()
  core.physics.world:removeBody(self.hitbox)
end

function Bullet:update(dt)
  local dirx, diry = math.cos(self.rot), math.sin(self.rot)
  self.x = self.x + dirx * self.speed * dt
  self.y = self.y + diry * self.speed * dt

  self.zIndex = self.y + 5

  self.lifetime = self.lifetime - dt

  local collider = self.hitbox:getFirstCollider()
  if collider and collider.anchor.health then
    local damage = self.damage
    if love.math.random() < self.critChance then
      damage = damage * self.critMod
    end
    collider.anchor.health:takeDamage(damage, dirx * 30, diry * 30)
  end
  if self.lifetime < 0 or collider then
    core.world:remove(self)
  end

  shadow.queueDraw(2, self.x, self.y + 5)
end

function Bullet:draw()
  love.graphics.setColor(1, 1, 0)
  love.graphics.circle("fill", self.x, self.y, 2)
end

return Bullet
