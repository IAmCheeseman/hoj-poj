local map = require("world_gen.map")
local ui = require("ui")
local weapons = require("weapons")

Hud = struct()

local heart = Sprite.create("assets/heart.ase")

local function pad0(str, zeros)
  local to_add = math.max(zeros - #str, 0)
  str = ("0"):rep(to_add) .. str
  return str
end

local function drawWeaponHud(id, y, is_offhand)
  if not weapons[id] then
    return
  end

  local limit = 48 / 2

  local first = weapons[id]

  local first_name = tr(first.name)
  local first_ammo = tostring(ammo[first.ammo].amount)

  local first_text = first_name .. " " .. first_ammo

  local first_width = math.max(ui.hud_font:getWidth(first_text) + 2, limit)

  local ammo_col = {1, 1, 0}
  local name_col = {1, 1, 1}
  if is_offhand then
    ammo_col = {0.5, 0.5, 0}
    name_col = {0.5, 0.5, 0.5}
  end

  love.graphics.printf(
    {
      ammo_col, first_ammo .. " ",
      name_col, first_name,
    },
    2, y, first_width, "center")
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

  do -- Level
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
      {
        {0, 1, 0.5}, "Level #",
        {0, 1, 0.5}, getDifficulty(),
      },
      0, 8,
      viewport.screenw, "center")
  end

  do -- Weapons
    drawWeaponHud(player_data.hand, texty, false)
    drawWeaponHud(player_data.offhand, texty + 8, true)
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

  if map.img then
    local dx = viewport.screenw - map.img:getWidth() - 2
    local dy = viewport.screenh - map.img:getHeight() - 2
    love.graphics.draw(map.img, dx, dy)

    local player = world.getSingleton("player")
    if player then
      local mmx = player.x / 16 - map.sx
      local mmy = player.y / 16 - map.sy
      love.graphics.setColor(0.1, 1, 0.2)
      love.graphics.points(mmx + dx, mmy + dy)
    end

    love.graphics.setColor(1, 0.1, 0.2)
    for _, enemy in ipairs(world.getTagged("enemy")) do
      local mmx = enemy.x / 16 - map.sx
      local mmy = enemy.y / 16 - map.sy
      love.graphics.points(mmx + dx, mmy + dy)
    end
  end
end
