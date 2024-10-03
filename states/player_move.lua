local state = require("state")

PlayerMove = state({})

function PlayerMove:step(dt)
  local obj = self.anchor

  local ix, iy = 0, 0
  if action.isDown("move_up")    then iy = iy - 1 end
  if action.isDown("move_left")  then ix = ix - 1 end
  if action.isDown("move_down")  then iy = iy + 1 end
  if action.isDown("move_right") then ix = ix + 1 end

  obj.sprite.layers["hands"].visible = not player_data.hand

  ix, iy = vec.normalized(ix, iy)

  obj.vx = mathx.dtLerp(obj.vx, ix * obj.speed, obj.frict, dt)
  obj.vy = mathx.dtLerp(obj.vy, iy * obj.speed, obj.frict, dt)
end
