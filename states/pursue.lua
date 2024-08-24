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
  self.dir = 0
end

function PursueState:step()
  local obj = self.anchor

  if self.timer <= 0 then
    local chance = 0
    local dir = 0
    local give_up = 0

    local tdirx, tdiry = vec.direction(
      obj.x, obj.y, obj.target.x, obj.target.y)

    repeat
      dir = mathx.frandom(0, mathx.tau)
      chance = (vec.dot(math.cos(dir), math.sin(dir), tdirx, tdiry) + 1) / 2
      give_up = give_up + 1
    until love.math.random() < chance^2 or give_up == 3

    self.dir = dir
    self.timer = love.math.random(15, 20)
  end

  self.timer = obj.s_pursue.timer - 1

  local dirx, diry =
      math.cos(self.dir),
      math.sin(self.dir)

  obj.vx = mathx.lerp(obj.vx, dirx * obj.speed, obj.accel)
  obj.vy = mathx.lerp(obj.vy, diry * obj.speed, obj.accel)
end
