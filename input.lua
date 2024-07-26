local Event = require("event")
local class = require("class")

local input = {}

local actions = {}
local keybinds = {}
local keyToName = {}
local mouseToName = {}

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
    error("Action '" .. action .. "' does not exist.", 1)
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

input.inputTriggered = Event()
input.keyPressed = Event()
input.keyReleased = Event()
input.mousePressed = Event()
input.mouseReleased = Event()
input.mouseMoved = Event()
input.mouseWheelMoved = Event()
input.textInput = Event()

local Input = class()

function Input:init(inputType)
  self.inputType = inputType
  self.eaten = false
end

function Input:isEaten()
  return self.eaten
end

function Input:eat()
  self.eaten = true
end

function Input:isType(inputType)
  return self.inputType == inputType
end

function Input:isActionPressed(action)
  return not self:isReleased() and self.action == action
end

function Input:isActionReleased(action)
  return self:isReleased() and self.action == action
end

function Input:isReleased()
  return self.released
end

function Input:isKeyDown(key)
  return self.key == key
end

function Input:isKeyRepeated()
  return self.repeated
end

function Input:isMouseDown(button)
  return not self:isReleased() and self.mouse == button
end

function Input:isMouseReleased(button)
  return self:isReleased() and self.mouse == button
end

function love.mousepressed(_, _, button, istouch, presses)
  local action = input.inputToAction("mouse", button)
  local i = Input("mousepressed")
  i.action = action
  i.mouse = button
  i.isTouch = istouch
  i.presses = presses

  input.inputTriggered:call(i)
  input.mousePressed:call(button, istouch, presses)
end

function love.mousereleased(_, _, button, istouch)
  local action = input.inputToAction("mouse", button)
  local i = Input("mousereleased")
  i.action = action
  i.released = true
  i.mouse = button
  i.isTouch = istouch

  input.inputTriggered:call(i)
  input.mouseReleased:call(button, istouch)
end

function love.mousemoved(_, _, rx, ry, istouch)
  local i = Input("mousemoved")
  i.rx = rx
  i.ry = ry
  i.isTouch = istouch

  input.inputTriggered:call(i)
  input.mouseMoved:call(rx, ry, istouch)
end

function love.keypressed(key, scancode, isrepeat)
  local action = input.inputToAction("kb", key)
  local i = Input("keypressed")
  i.action = action
  i.key = key
  i.scancode = scancode
  i.repeated = isrepeat

  input.inputTriggered:call(i)
  input.keyPressed:call(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
  local action = input.inputToAction("kb", key)
  local i = Input("keyreleased")
  i.action = action
  i.released = true
  i.key = key
  i.scancode = scancode

  input.inputTriggered:call(i)
  input.keyReleased:call(key, scancode)
end

function love.textinput(text)
  input.textInput:call(text)
end

function love.wheelmoved(x, y)
  input.mouseWheelMoved:call(x, y)
end

return input
