local vec = {}

function vec.dot(x, y, xx, yy)
  return x * xx + y * yy
end

function vec.len(x, y)
  return math.sqrt(x^2 + y^2)
end

function vec.lenSq(x, y)
  return x^2 + y^2
end

function vec.normalized(x, y)
  local l = vec.len(x, y)
  if l ~= 0 then
    return x / l, y / l
  end
  return 0, 0
end

function vec.direction(x, y, xx, yy)
  return vec.normalized(xx - x, yy - y)
end

function vec.distance(x, y, xx, yy)
  return math.sqrt((xx - x)^2 + (yy - y)^2)
end

function vec.distanceSq(x, y, xx, yy)
  return (xx - x)^2 + (yy - y)^2
end

function vec.angle(x, y)
  return math.atan2(y, x)
end

function vec.reflect(dirx, diry, nx, ny)
  local rx, ry = 0, 0
  local dot = vec.dot(dirx, diry, nx, ny)
  rx = dirx - 2 * dot * nx
  ry = diry - 2 * dot * ny
  return rx, ry
end

return vec
