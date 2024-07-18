local class = require("class")

local StateMachine = class()

function StateMachine:init(anchor, defaultState)
  self.anchor = anchor
  self.state = defaultState
end

function StateMachine:setState(to)
  if self.state.exit then
    self.state.exit(self.anchor)
  end

  self.state = to

  if self.state.enter then
    self.state.enter(self.anchor)
  end
end

function StateMachine:call(funcName, ...)
  local func = self.state[funcName]
  if func then
    func(self.anchor, ...)
  end
end

return StateMachine
