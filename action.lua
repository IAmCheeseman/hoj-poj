local settings = require("settings")
local action = {}

local actions = {}

local function ensureActionExists(name)
  if not actions[name] then
    error("Action '" .. tostring(name) .. "' does not exist", 2)
  end
end

function action.define(name, input_type, input)
  local keybind = settings.keybinds[name] or {
    type = input_type,
    input = input
  }

  actions[name] = {
    type = keybind.type,
    input = keybind.input,
    just_pressed = false,
  }
end

function action.step()
  for k, v in pairs(actions) do
    v.just_pressed = false

    if action.isDown(k) then
      if not v.pressed then
        v.just_pressed = true
      end
      v.pressed = true
    else
      v.pressed = false
    end
  end
end

function action.isJustDown(name)
  ensureActionExists(name)

  local a = actions[name]
  return a.just_pressed
end

function action.isDown(name)
  ensureActionExists(name)

  local a = actions[name]
  if a.type == "key" then
    return love.keyboard.isDown(a.input)
  elseif a.type == "mouse" then
    return love.mouse.isDown(a.input)
  end
end

return action
