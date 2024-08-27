local weapons = require("weapons")

AmmoCrate = struct()

local ammo_crate_sprite = Sprite.create("assets/ammo_crate.png")
ammo_crate_sprite:offset("center", "center")

sound.load("ammo_pickup", "assets/ammo_pickup.wav", 2)

function AmmoCrate:new()
  self.sprite = ammo_crate_sprite
  self.lifetime = 6
end

local function selectAmmo(player)
  local opts = {player.hand, player.offhand}
  local select = love.math.random() < 0.6 and 2 or 1
  local weapon = weapons[opts[select]]
  table.remove(opts, select)
  local ammo_type = weapon.ammo

  if ammo[ammo_type].amount == ammo[ammo_type].max then
    weapon = weapons[opts[1]]
    ammo_type = weapon.ammo
  end

  return ammo_type
end

function AmmoCrate:step(dt)
  self.z_index = self.y

  self.lifetime = self.lifetime - dt
  if self.lifetime <= 0 then
    world.rem(self)
  end

  local player = world.getSingleton("player")
  if player then
    if vec.distanceSq(self.x, self.y, player.x, player.y) < 16^2 then
      local ammo_type = selectAmmo(player)

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
