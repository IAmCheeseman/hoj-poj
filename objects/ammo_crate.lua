local weapons = require("weapons")

AmmoCrate = struct()

local ammo_crate_sprite = Sprite.create("assets/ammo_crate.png")
ammo_crate_sprite:offset("center", "center")

sound.load("ammo_pickup", "assets/ammo_pickup.wav", 2)

function AmmoCrate:new()
  self.sprite = ammo_crate_sprite
  self.lifetime = 6
end

local function getRandomAmmoType()
  local types = getAmmoTypes()
  local name
  for _=1, 10 do
    name = types[love.math.random(1, #types)]
    local type = ammo[name]
    if type.amount ~= type.max then
      return name
    end
  end
  return name
end

local function selectAmmo()
  local opts = {player_data.hand, player_data.offhand}
  local remove = {}
  for i, v in ipairs(opts) do
    local weapon = v:getWeapon()
    if not weapon then
      table.insert(remove, i)
    else
      local ammo_type = weapon.ammo
      if ammo[ammo_type].count == ammo[ammo_type].max then
        table.insert(remove, i)
      end
    end
  end

  for _, v in ipairs(remove) do
    table.remove(opts, v)
  end

  if #opts == 0 then
    return getRandomAmmoType()
  else
    local idx = love.math.random() < 0.5 and #opts or 1
    local weapon = opts[idx]:getWeapon() or {ammo="bullet"}
    return weapon.ammo
  end
end

function AmmoCrate:step(dt)
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
      local ammo_type = selectAmmo()

      ammo[ammo_type].amount = math.min(
        ammo[ammo_type].amount + ammo[ammo_type].crate_amount,
        ammo[ammo_type].max)

      local te = TextEffect:create(
        "+" .. tostring(ammo[ammo_type].crate_amount) .. " "
        .. tr(ammo[ammo_type].name) .. "!",
        self.x, self.y, {1, 1, 0})
      world.add(te)

      world.rem(self)

      sound.play("ammo_pickup")
    end

    if vec.distanceSq(self.x, self.y, player.x, player.y) < 32^2 then
      self.x = mathx.dtLerp(self.x, player.x, 10, dt)
      self.y = mathx.dtLerp(self.y, player.y, 10, dt)
    end
  end
end

function AmmoCrate:draw()
  local stepped = mathx.snap(self.lifetime, 0.1) * 10
  if self.lifetime < 1 and stepped % 2 == 0 then
    return
  end

  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y)
end
