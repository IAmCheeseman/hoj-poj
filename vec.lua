local vec = {}

function vec.dot(x, y, xx, yy)
  return x * xx + y * yy
end

function vec.cross(x, y, xx, yy)
  return x * xx - y * yy
end

function vec.length(x, y)
  return math.sqrt(x^2 + y^2)
end

function vec.normalize(x, y)
  local l = vec.length(x, y)
  if l == 0 then
    return 0, 0
  end
  return x / l, y / l
end

function vec.angle(x, y)
  return math.atan2(y, x)
end

function vec.distance(x, y, xx, yy)
  return vec.length(xx - x, yy - y)
end

function vec.direction(x, y, xx, yy)
  return vec.normalize(xx - x, yy - y)
end

function vec.angleTo(x, y, xx, yy)
  return math.atan2(vec.cross(x, y, xx, yy), vec.dot(x, y, xx, yy))
end

function vec.angleToPoint(x, y, px, py)
  return vec.angle(px - x, py - y)
end

return vec
