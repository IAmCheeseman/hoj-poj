BasicBullet = struct()

function BasicBullet:new(x, y, angle, speed, damage, sprite, lifetime)
  self.x = x
  self.y = y
  self.vx = math.cos(angle) * speed
  self.vy = math.sin(angle) * speed
  self.rot = angle
  self.sprite = sprite
  self.lifetime = lifetime or (max_fps * 5)
  self.damage = damage

  local size = math.min(sprite.width, sprite.height)
  self.body = Body.create(self, shape.offsetRect(
    -size / 2, -size / 2, size, size))
end

function BasicBullet:step()
  self.lifetime = self.lifetime - 1
  if self.lifetime < 0 then
    world.rem(self)
  end

  self.x = self.x + self.vx
  self.y = self.y + self.vy

  self.z_index = self.y - 8

  local colls = self.body:getAllCollisions({"env", "damagable"})

  for _, coll in ipairs(colls) do
    if coll.tag == "damagable" then
      local kbx, kby = vec.normalized(self.vx, self.vy)
      local res = coll.obj.health:takeDamage({damage=self.damage, kbx=kbx, kby=kby})

      if res then
        world.rem(self)
      end
    else
      world.rem(self)
    end
  end
end

function BasicBullet:removed()
  local effect = Effect:create("assets/dust.ase", true)
  effect.x = self.x
  effect.y = self.y
  world.add(effect)
end
