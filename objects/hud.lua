local ui = require("ui")
local weapons = require("weapons")

Hud = struct()

local heart = Sprite.create("assets/heart.ase")

local function pad0(str, zeros)
  local to_add = math.max(zeros - #str, 0)
  str = ("0"):rep(to_add) .. str
  return str
end

function Hud:gui()
  love.graphics.setFont(ui.hud_font)
  local texty = 0

  do -- HP
    love.graphics.setColor(1, 1, 1)
    for i=0, player_data.health.max_hp - 1 do
      if player_data.health.hp > i then
        heart.frame = 1
      else
        heart.frame = 2
      end
      heart:draw(2 + i * heart.width, 2)
    end

    texty = texty + math.floor(heart.height * 1.2)
  end

  do -- Timer
    local minutes = math.floor(getKillTimer() / 60)
    local seconds = getKillTimer() - minutes * 60

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
      {
        {0, 1, 0.5}, pad0(tostring(minutes), 2) .. ":" .. pad0(tostring(seconds), 2),
      },
      0, 0,
      viewport.screenw, "center")
  end

  do -- Weapons
    local limit = 48 / 2

    local first = weapons[player_data.hand]
    local other = weapons[player_data.offhand]

    local first_name = tr(first.name)
    local other_name = tr(other.name)
    local first_ammo = tostring(ammo[first.ammo].amount)
    local other_ammo = tostring(ammo[other.ammo].amount)

    local first_text = first_name .. " " .. first_ammo
    local other_text = other_name .. " " .. other_ammo

    local first_width = math.max(ui.hud_font:getWidth(first_text) + 2, limit)
    local other_width = math.max(ui.hud_font:getWidth(other_text) + 2, limit)

    local firsty = texty
    local othery = texty + 8

    love.graphics.printf(
      {
        {1, 1, 0}, first_ammo .. " ",
        {1, 1, 1}, first_name,
      },
      2, firsty, first_width, "center")

    love.graphics.printf(
      {
        {0.6, 0.4, 0}, other_ammo .. " ",
        {0.5, 0.5, 0.5}, other_name,
      },
      2, othery, other_width, "center")
  end

  if player_data.health.dead then
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, viewport.screenw, viewport.screenh)

    love.graphics.setColor(1, 1, 1)
    local centery = viewport.screenh / 2 - ui.hud_font:getHeight() / 2
    love.graphics.printf(
      {
        {1, 1, 1}, "You ",
        {1, 0, 0}, " died",
        {1, 1, 1}, " :[",
      },
      0, centery, viewport.screenw, "center")
  end
end
