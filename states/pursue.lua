local state = require("state")

PursueState = state({
  x = "number",
  y = "number",
  vx = "number",
  vy = "number",
  speed = "number",
  accel = "number",
})

function PursueState:new(on_direction_changed)
  self.pursue_time_min = 0.5
  self.pursue_time_max = 0.7
  self.timer = 0
  self.dirx = 0
  self.diry = 0
  self.on_direction_changed = on_direction_changed
end

function PursueState:step(dt)
  local obj = self.anchor

  if self.timer <= 0 then
    local dirx, diry = vec.direction(
      obj.x, obj.y, obj.target.x, obj.target.y)

    dirx, diry = vec.rotate(dirx, diry, mathx.frandom(-math.pi / 2, math.pi / 2))

    if love.math.random() < 0.1 then
      dirx = -dirx
      diry = -diry
    end

    self.dirx = dirx
    self.diry = diry
    self.timer = mathx.frandom(self.pursue_time_min, self.pursue_time_max)

    try(self.on_direction_changed, self.anchor)
  end

  self.timer = obj.s_pursue.timer - dt

  obj.vx = mathx.dtLerp(obj.vx, self.dirx * obj.speed, obj.accel, dt)
  obj.vy = mathx.dtLerp(obj.vy, self.diry * obj.speed, obj.accel, dt)
end
