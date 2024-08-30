local state = require("state")

IdleState = state({
  x = "number",
  y = "number",
  vx = "number",
  vy = "number",
  speed = "number",
  accel = "number",
})

function IdleState:new(on_enter, on_timer_over)
  self.on_enter = on_enter
  self.on_timer_over = on_timer_over

  self.idle_time_min = 0.9
  self.idle_time_max = 1.2
end

function IdleState:enter()
  try(self.on_enter, self.anchor)
  self.time = mathx.frandom(self.idle_time_min, self.idle_time_max)
end

function IdleState:step(dt)
  local obj = self.anchor

  obj.vx = mathx.dtLerp(obj.vx, 0, obj.accel, dt)
  obj.vy = mathx.dtLerp(obj.vy, 0, obj.accel, dt)

  self.time = self.time - dt
  if self.time <= 0 then
    try(self.on_timer_over, self.anchor)
  end
end
