BasicBullet = struct()

function BasicBullet:new(opts)
  self.x = opts.x
  self.y = opts.y
  self.vx = math.cos(opts.angle) * opts.speed
  self.vy = math.sin(opts.angle) * opts.speed
  self.speed = opts.speed
  self.rot = opts.angle
  self.sprite = opts.sprite
  self.max_lifetime = opts.lifetime or (max_fps * 5)
  self.lifetime = self.max_lifetime
  self.damage = opts.damage
  self.bounce = opts.bounce or 0
  self.bounce_damage_mod = opts.bounce_damage_mod or 1
  self.slow_down = opts.slow_down
  self.ignore_tags = opts.ignore_tags
  self.animate_with_lifetime = opts.animate_with_lifetime

  local size = math.min(opts.sprite.width, opts.sprite.height)
  self.body = Body.create(self, shape.offsetRect(
    -size / 2, -size / 2, size, size))
end

function BasicBullet:step()
  self.lifetime = self.lifetime - 1
  if self.lifetime < 0 then
    world.rem(self)
  end

  if self.slow_down then
    local p = (self.lifetime / self.max_lifetime + 0.2) / 1.2
    self.vx = math.cos(self.rot) * self.speed * p
    self.vy = math.sin(self.rot) * self.speed * p
  end

  self.x = self.x + self.vx
  self.y = self.y + self.vy

  self.z_index = self.y - 8

  local colls = self.body:getAllCollisions({"env", "damagable"})

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
        local res = coll.obj.health:takeDamage({damage=self.damage, kbx=kbx, kby=kby})

        if res then
          world.rem(self)
        end
      end
    else
      if self.bounce > 0 then
        self.x = self.x + coll.resolvex
        self.y = self.y + coll.resolvey
        self.vx, self.vy = vec.reflect(self.vx, self.vy, coll.axisx, coll.axisy)
        self.rot = vec.angle(self.vx, self.vy)
        self.lifetime = self.lifetime * 0.75
        self.damage = self.damage * self.bounce_damage_mod
        self.bounce = self.bounce - 1
      else
        world.rem(self)
      end
    end
  end
end

function BasicBullet:removed()
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
  love.graphics.setBlendMode("add")
  self.sprite:draw(self.x, self.y, self.rot)
  love.graphics.setBlendMode("alpha")
end
