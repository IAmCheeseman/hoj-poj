local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.create(anchor, default)
  local sm = setmetatable({}, StateMachine)
  sm.anchor = anchor
  sm.current_state = default
  return sm
end

function StateMachine:setState(state)
  local _ = try(self.current_state.exit, self.current_state)
  self.current_state = state
  local _ = try(self.current_state.enter, self.current_state)
end

function StateMachine:call(fn_name, ...)
  local _ = try(self.current_state[fn_name], self.current_state, ...)
end

return StateMachine
