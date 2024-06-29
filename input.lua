local Event = require("event")

local input = {}

local actions = {}
local keytoname = {}
local mousetoname = {}

function input.addAction(name, type, id)
  actions[name] = {type=type, id=id}
  if type == "kb" then
    keytoname[id] = name
  elseif type == "mouse" then
    mousetoname[id] = name
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
    return keytoname[id]
  elseif type == "mouse" then
    return mousetoname[id]
  end
  return nil
end

input.actionTriggered = Event()

function love.keypressed(key, _, isrepeat)
  local action = input.inputToAction("kb", key)
  input.actionTriggered:call(action, key, isrepeat)
end

return input
