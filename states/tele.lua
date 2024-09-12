local state = require("state")

TeleState = state({
  vx = "number",
  vy = "number",
})

function TeleState:new(target_state, tele_time)
  self.target_state = target_state
  self.tele_time = tele_time
  self.time = 0
  self.anim = "dtele"
end

function TeleState:enter()
  self.time = self.tele_time
end

function TeleState:step(dt)
  self.time = self.time - dt
  if self.time < 0 then
    self.anchor.sm:setState(self.target_state)
  end
end
