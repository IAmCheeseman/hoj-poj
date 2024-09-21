local settings = require("settings")
local action = {}

local joysticks = love.joystick.getJoysticks()
action.joystick_deadzone = 0.5
action.using_joystick = false
action.joystick = joysticks[1]

local actions = {}

local function ensureActionExists(name)
  if not actions[name] then
    error("Action '" .. tostring(name) .. "' does not exist", 2)
  end
end

function action.define(name, inputs)
  local keybind = settings.keybinds[name] or inputs

  actions[name] = {
    inputs = keybind,
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

  local inputs = actions[name].inputs
  for _, a in ipairs(inputs) do
    if a.method == "key" then
      local down = love.keyboard.isDown(a.input)
      if down then
        action.using_joystick = false
        return true
      end
    elseif a.method == "mouse" then
      local down = love.mouse.isDown(a.input)
      if down then
        action.using_joystick = false
        return true
      end
    elseif a.method == "jsbtn" then
      local down = action.joystick:isGamepadDown(a.input)
      if down then
        action.using_joystick = true
        return true
      end
    elseif a.method == "jsaxis" then
      local axis = action.joystick:getGamepadAxis(a.input.axis)
      local down = false
      if math.abs(axis) > action.joystick_deadzone then
        if a.input.dir == 1 then
          down = axis > 0
        else
          down = axis < 0
        end
      end

      if down then
        action.using_joystick = true
        return true
      end
    end
  end

  return false
end

return action
