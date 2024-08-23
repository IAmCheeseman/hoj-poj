local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.create(anchor, default)
  local sm = setmetatable({}, StateMachine)
  sm.anchor = anchor
  sm.current_state = default
  return sm
end

function StateMachine:setState(state)
  local _ = try(self.current_state.exit, self.anchor)
  self.current_state = state
  local _ = try(self.current_state.enter, self.anchor)
end

function StateMachine:call(fn_name, ...)
  local _ = try(self.current_state[fn_name], self.anchor, ...)
end

return StateMachine
