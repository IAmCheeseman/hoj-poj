function try(fn, ...)
  if type(fn) == "function" then
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

function tablex.print(t, i, ts)
  i = i or 0
  ts = ts or {}
  if ts[t] then
    io.write("{...}")
    return
  end
  ts[t] = true

  io.write("{\n")
  for k, v in pairs(t) do
    io.write(("\t"):rep(i + 1))
    if type(k) == "string" then
      io.write(k)
    else
      io.write("[" .. tostring(k) .. "]")
    end

    if type(v) == "table" then
      ts[v] = true
      io.write(" = ")
      tablex.print(v, i + 1, ts)
      io.write(", \n")
    elseif type(v) == "string" then
      io.write(" = \"" .. v .. "\",\n")
    else
      io.write(" = " .. tostring(v) .. ",\n")
    end
  end
  io.write("}")
  if i == 0 then
    io.write("\n")
  end
end

mathx = {}

mathx.tau = math.pi * 2

function mathx.lerp(x, y, d)
  return (y - x) * d + x
end

function mathx.dtLerp(x, y, d, dt)
  return (x - y) * 0.5^(dt * d) + y
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
