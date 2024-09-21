local json = require("json")
local settings_file = "settings.json"
local default_settings = {
  screenshake = 1,
  hemophobia = false,
  autoaim = 1,
  keybinds = {},
}
local settings = {}

function saveSettings()
  love.filesystem.write(settings_file, json.encode(settings))
end

local function loadSettings()
  -- Basically: load settings, then fill in any missing settings with defaults

  local contents, _ = love.filesystem.read(settings_file)
  if contents then
    settings = json.decode(contents)
  end

  local changed = false
  for k, v in pairs(default_settings) do
    if not settings[k] then
      settings[k] = v
      changed = true
    end
  end

  if changed then
    saveSettings()
  end
end

loadSettings()

return settings
