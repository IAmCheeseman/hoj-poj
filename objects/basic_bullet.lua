local weapon_common = require("weapon_common")
BasicBullet = struct()

function BasicBullet:new(t, opts)
  self.x = opts.x or error("Expected x property")
  self.y = opts.y or error("Expected y proeprty")
  if opts.dirx and opts.diry then
    self.vx = opts.dirx
    self.vy = opts.diry
    self.speed = vec.len(opts.dirx, opts.diry)
    self.rot = vec.angle(opts.dirx, opts.diry)
  else
    local angle = opts.angle
    local accuracy = opts.accuracy or 0
    if t.dual_wielding then
      accuracy = accuracy * weapon_common.dual_accuracy_mod
    end
    angle = angle + math.rad(mathx.frandom(-accuracy, accuracy))
    self.vx = math.cos(angle) * opts.speed
    self.vy = math.sin(angle) * opts.speed
    self.speed = opts.speed or error("Expected speed property")
    self.rot = angle or error("Expected angle property")
  end
  self.sprite = opts.sprite or error("Expected sprite property")
  self.max_lifetime = opts.lifetime or 999
  self.lifetime = self.max_lifetime
  self.damage = opts.damage or error("Expected damage property")
  self.bounce = opts.bounce or 0
  self.pierce = opts.pierce
  self.bounce_damage_mod = opts.bounce_damage_mod or 1
  self.slow_down = opts.slow_down
  self.ignore_tags = opts.ignore_tags or {}
  self.animate_with_lifetime = opts.animate_with_lifetime

  local size = math.min(opts.sprite.width, opts.sprite.height)
  self.body = Body.create(self, shape.offsetRect(
    -size / 2, -size / 2, size, size))
end

function BasicBullet:step(dt)
  self.lifetime = self.lifetime - dt
  if self.lifetime < 0 then
    self:poof()
    world.rem(self)
  end

  if self.slow_down then
    local p = (self.lifetime / self.max_lifetime + 0.2) / 1.2
    self.vx = math.cos(self.rot) * self.speed * p
    self.vy = math.sin(self.rot) * self.speed * p
  end

  self.z_index = self.y - 8

  local colls = self.body:getAllCollisions(self.vx, self.vy, dt, {"env", "damagable"})
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt

  for _, coll in ipairs(colls) do
    if coll.tag == "damagable" then
      local should_ignore = false

      for _, tag in ipairs(self.ignore_tags) do
        if world.isTagged(coll.obj, tag) then
          should_ignore = true
          break
        end
      end

      if not should_ignore then
        local kbx, kby = vec.normalized(self.vx, self.vy)
        local health = coll.obj.health
        local res = health:takeDamage({damage=self.damage, kbx=kbx, kby=kby})

        local can_pierce = health.dead and self.pierce

        if res and not can_pierce then
          world.rem(self)
        end
      end
    else
      if self.bounce > 0 then
        self.x = self.x + coll.resolvex
        self.y = self.y + coll.resolvey
        self.vx, self.vy = vec.reflect(self.vx, self.vy, coll.axisx, coll.axisy)
        self.rot = vec.angle(self.vx, self.vy)
        self.damage = self.damage * self.bounce_damage_mod
        self.bounce = self.bounce - 1
      else
        self:poof()
        world.rem(self)
      end
    end
  end
end

function BasicBullet:poof()
  local effect = Effect:create("assets/dust.ase", true)
  effect.x = self.x
  effect.y = self.y
  world.add(effect)
end

function BasicBullet:draw()
  if self.animate_with_lifetime then
    local p = 1 - (self.lifetime / self.max_lifetime)
    local frame = math.max(1, math.floor(p * #self.sprite.frames))
    self.sprite.frame = frame
  end

  love.graphics.setColor(1, 1, 1)
  -- love.graphics.setBlendMode("add")
  self.sprite:draw(self.x, self.y, self.rot)
  -- love.graphics.setBlendMode("alpha")
end
