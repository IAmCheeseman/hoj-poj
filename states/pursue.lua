local state = require("state")

PursueState = state({
  x = "number",
  y = "number",
  vx = "number",
  vy = "number",
  speed = "number",
  accel = "number",
})

function PursueState:new()
  self.timer = 0
  self.dirx = 0
  self.diry = 0
end

function PursueState:step()
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
    self.timer = love.math.random(15, 20)
  end

  self.timer = obj.s_pursue.timer - 1

  obj.vx = mathx.lerp(obj.vx, self.dirx * obj.speed, obj.accel)
  obj.vy = mathx.lerp(obj.vy, self.diry * obj.speed, obj.accel)
end
