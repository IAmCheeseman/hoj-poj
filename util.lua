function try(fn, ...)
  if fn then
    return true, fn(...)
  end
  return false
end

function is(val, type_name)
  return type(val) == type_name
end

tablex = {}

function tablex.swapRem(t, i)
  local old = t[i]
  local new = t[#t]

  t[i] = new
  t[#t] = nil

  return old, new
end

mathx = {}

mathx.tau = math.pi * 2

function mathx.lerp(x, y, d)
  return (y - x) * d + x
end

function mathx.frandom(min, max)
  local r = love.math.random()
  return r * (max - min) + min
end

function mathx.snap(a, s)
  return math.floor(a / s) * s
end

function mathx.sign(a)
  if a == 0 then
    return 0
  end

  return a < 0 and -1 or 1
end
