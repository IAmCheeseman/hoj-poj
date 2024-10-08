MedKit = struct()

local med_kit_sprite = Sprite.create("assets/medkit.png")
med_kit_sprite:offset("center", "center")

sound.load("medkit_pickup", "assets/medkit.wav", 2)

function MedKit:new()
  self.sprite = med_kit_sprite
  self.lifetime = 6
end

function MedKit:step(dt)
  self.z_index = self.y

  self.lifetime = self.lifetime - dt
  if self.lifetime <= 0 then
    local poof = Effect:create("assets/dust.ase", true)
    poof.x = self.x
    poof.y = self.y
    world.add(poof)
    world.rem(self)
  end

  local player = world.getSingleton("player")
  if player then
    if vec.distanceSq(self.x, self.y, player.x, player.y) < 16^2 then
      player_data.health:heal(1)

      local te = TextEffect:create("+1 HP!", self.x, self.y, {1, 0.2, 0.3})
      world.add(te)

      world.rem(self)

      sound.play("medkit_pickup")
    end

    if vec.distanceSq(self.x, self.y, player.x, player.y) < 32^2 then
      self.x = mathx.dtLerp(self.x, player.x, 10, dt)
      self.y = mathx.dtLerp(self.y, player.y, 10, dt)
    end
  end
end

function MedKit:draw()
  local stepped = mathx.snap(self.lifetime, 0.1) * 10
  if self.lifetime < 1 and stepped % 2 == 0 then
    return
  end

  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y)
end
