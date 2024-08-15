local Event = require("event")

local input = {}

local actions = {}
local keybinds = {}
local keyToName = {}
local mouseToName = {}

local mouseButtonNames = {
  [1] = "LMB",
  [2] = "RMB",
  [3] = "MMB",
}

function input.addKeybind(name, ...)
  local args = {...}
  if #args % 2 ~= 0 then
    error("Wrong number of args.", 1)
  end

  local bind = {}
  local i = 1
  while i <= #args do
    local t = args[i]
    local id = args[i + 1]
    table.insert(bind, {
      type = t,
      id = id,
    })
    i = i + 2
  end

  keybinds[name] = bind
end

function input.getActionDisplay(name)
  local action = actions[name]
  if not action then
    error("Action '" .. name .. "' does not exist.", 1)
  end

  if action.type == "kb" then
    return action.id:upper()
  elseif action.type == "mouse" then
    return mouseButtonNames[action.id] or ("MB" .. action.id)
  end
end

function input.isKeybindPressed(name)
  local keybind = keybinds[name]
  if not keybind then
    error("keybind '" .. keybind .. "' does not exist.", 1)
  end

  local allPressed = true
  for _, action in ipairs(keybind) do
    if action.type == "kb" then
      allPressed = allPressed and love.keyboard.isDown(action.id)
    elseif action.type == "mouse" then
      allPressed = allPressed and love.mouse.isDown(action.id)
    end
  end

  return allPressed
end

function input.addAction(name, type, id)
  actions[name] = {type=type, id=id}
  if type == "kb" then
    keyToName[id] = name
  elseif type == "mouse" then
    mouseToName[id] = name
  end
end

function input.isActionDown(name)
  local action = actions[name]
  if not action then
    error("Action '" .. tostring(name) .. "' does not exist.", 1)
  end

  if action.type == "kb" then
    return love.keyboard.isDown(action.id)
  elseif action.type == "mouse" then
    return love.mouse.isDown(action.id)
  end
end

function input.inputToAction(type, id)
  if type == "kb" then
    return keyToName[id]
  elseif type == "mouse" then
    return mouseToName[id]
  end
  return nil
end

input.actionTriggered = Event()
input.actionReleased = Event()
input.keyPressed = Event()
input.keyReleased = Event()
input.mousePressed = Event()
input.mouseReleased = Event()
input.mouseMoved = Event()
input.mouseWheelMoved = Event()
input.textInput = Event()

function love.mousepressed(_, _, button, istouch, presses)
  local action = input.inputToAction("mouse", button)
  input.actionTriggered:call(action, button)
  input.mousePressed:call(button, istouch, presses)
end

function love.mousereleased(_, _, button, istouch)
  local action = input.inputToAction("mouse", button)
  input.actionReleased:call(action, button)
  input.mouseReleased:call(button, istouch)
end

function love.mousemoved(_, _, rx, ry, istouch)
  input.mouseMoved:call(rx, ry, istouch)
end

function love.keypressed(key, scancode, isrepeat)
  local action = input.inputToAction("kb", key)
  input.actionTriggered:call(action, key, isrepeat)
  input.keyPressed:call(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
  local action = input.inputToAction("kb", key)
  input.actionReleased:call(action, key)
  input.keyReleased:call(key, scancode)
end

function love.textinput(text)
  input.textInput:call(text)
end

function love.wheelmoved(x, y)
  input.mouseWheelMoved:call(x, y)
end

return input
