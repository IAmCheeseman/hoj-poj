local weapons = require("weapons")

AmmoCrate = struct()

local ammo_crate_sprite = Sprite.create("assets/ammo_crate.png")
ammo_crate_sprite:offset("center", "center")

function AmmoCrate:new()
  self.sprite = ammo_crate_sprite
end

local function selectAmmo(player)
  local opts = {player.hand, player.offhand}
  local select = love.math.random(1, #opts)
  local weapon = weapons[opts[select]]
  table.remove(opts, select)
  local ammo_type = weapon.ammo

  if ammo[ammo_type].amount == ammo[ammo_type].max then
    weapon = weapons[opts[1]]
    ammo_type = weapon.ammo
  end

  return ammo_type
end

function AmmoCrate:step()
  self.z_index = self.y

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
        self.x, self.y)
      world.add(te)

      world.rem(self)
    end
  end
end
