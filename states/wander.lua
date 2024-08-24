local state = require("state")

WanderState = state({
  x = "number",
  y = "number",
  vx = "number",
  vy = "number",
  speed = "number",
  accel = "number",
})

function WanderState:new(main_target)
  self.main_target = main_target
  self.timer = 0
  self.dir = 0
end

function WanderState:step()
  local obj = self.anchor

  local target = world.getSingleton(self.main_target)
  if not target then
    return
  end

  local dist = vec.distanceSq(obj.x, obj.y, target.x, target.y)
  if dist < obj.aggro_dist^2 then
    obj:tellTarget(target)
  end

  -- Choose to wander more or stay in place
  if self.timer <= 0 then
    if love.math.random() < 0.5 then
      self.dir = mathx.frandom(0, mathx.tau)
      self.timer = love.math.random(15)
    else
      self.dir = 0
      self.timer = love.math.random(15, 30)
    end
  end

  self.timer = self.timer - 1

  local dirx, diry = 0, 0
  if self.dir ~= 0 then
    dirx, diry =
      math.cos(self.dir),
      math.sin(self.dir)
  end

  obj.vx = mathx.lerp(obj.vx, dirx * obj.speed, obj.accel)
  obj.vy = mathx.lerp(obj.vy, diry * obj.speed, obj.accel)
end
