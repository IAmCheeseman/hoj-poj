local state = require("state")

JumpAttackState = state({
  x = "number",
  y = "number",
  vx = "number",
  vy = "number",
  target = "table",
})

function JumpAttackState:new(on_jump_over)
  self.startx = 0
  self.starty = 0
  self.dirx = 0
  self.diry = 0
  self.jump_distance = 0
  self.jump_speed = 350
  self.jump_before = 32

  self.jump_height = 0
  self.max_jump_height = 10
  self.on_jump_over = on_jump_over
end

function JumpAttackState:enter()
  local obj = self.anchor
  self.startx, self.starty = obj.x, obj.y
  self.dirx, self.diry = vec.direction(obj.x, obj.y, obj.target.x, obj.target.y)
  self.jump_distance =
    vec.distance(obj.x, obj.y, obj.target.x, obj.target.y) - self.jump_before
end

function JumpAttackState:step(dt)
  local obj = self.anchor

  obj.vx = self.dirx * self.jump_speed
  obj.vy = self.diry * self.jump_speed

  local jump_len = vec.distance(self.startx, self.starty, obj.x, obj.y)
  local p = jump_len / self.jump_distance
  self.jump_height = math.sin(math.pi * p) * self.max_jump_height

  if jump_len > self.jump_distance then
    self.dirx = 0
    self.diry = 0
    self.jump_height = 0

    try(self.on_jump_over, self.anchor)
  end
end
