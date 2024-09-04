local ui = require("ui")
local weapons = require("weapons")

Hud = struct()

local function pad0(str, zeros)
  local to_add = math.max(zeros - #str, 0)
  str = ("0"):rep(to_add) .. str
  return str
end

function Hud:gui()
  local player = world.getSingleton("player") or self.player
  self.player = player

  if not player then
    return
  end

  love.graphics.setFont(ui.hud_font)
  local texty = viewport.screenh - ui.hud_font:getHeight() * 1.25

  do -- Score
    local combo_time, max_combo_time = getComboTime()
    local comboy = texty - 3
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 1, comboy, 64, 2)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 1, comboy, 64 * (combo_time / max_combo_time), 2)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
      {
        {1, 1, 1}, tr("hud_score") .. " ",
        {1, 1, 0}, pad0(tostring(getScore()), 7),
        {0, 1, 0}, " *" .. tostring(getCombo()),
      },
      1, texty,
      viewport.screenw, "left")
  end

  do -- HP
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
      {
        {1, 1, 1}, tr("hud_hp") .. " ",
        {1, 0, 0}, pad0(tostring(player.health.hp), 2),
        {1, 1, 1}, "/",
        {0.5, 0.5, 0.5}, tostring(player.health.max_hp),
      },
      0, texty,
      viewport.screenw, "center")
  end

  do -- Timer
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
      {
        {1, 1, 1}, tr("hud_time") .. " ",
        {0, 1, 0.5}, pad0(tostring(getKillTimer()), 2),
      },
      0, texty - ui.hud_font:getHeight(),
      viewport.screenw, "center")
  end

  do -- Weapons
    local limit = 48 / 2

    local first = weapons[player.hand]
    local other = weapons[player.offhand]

    local first_name = tr(first.name)
    local other_name = tr(other.name)
    local first_ammo = tostring(ammo[first.ammo].amount)
    local other_ammo = tostring(ammo[other.ammo].amount)

    local first_text = first_name .. " " .. first_ammo
    local other_text = other_name .. " " .. other_ammo

    local first_width = math.max(ui.hud_font:getWidth(first_text) + 2, limit)
    local other_width = math.max(ui.hud_font:getWidth(other_text) + 2, limit)

    local firstx = viewport.screenw - other_width - first_width
    local otherx = viewport.screenw - other_width

    love.graphics.printf(
      {
        {1, 1, 1}, first_name .. " ",
        {1, 1, 0}, first_ammo,
      },
      firstx, texty, first_width, "center")

    love.graphics.printf(
      {
        {0.5, 0.5, 0.5}, other_name .. " ",
        {0.6, 0.4, 0}, other_ammo,
      },
      otherx, texty, other_width, "center")
  end

  if player.health.dead then
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
