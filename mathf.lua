local mathf = {}

function mathf.lerp(a, b, d)
  return (b - a) * d + a
end

function mathf.dtLerp(a, b, d)
  return (a - b) * 0.5^(love.timer.getDelta() * d) + b
end

function mathf.angleDiff(a, b)
  local diff = (b - a) % (math.pi * 2)
  return (2 * diff) % (math.pi * 2) - diff
end

function mathf.lerpAngle(a, b, d)
  return a + mathf.angleDiff(a, b) * (1 - 0.5^d)
end

function mathf.frac(a)
  return a - math.floor(a)
end

function mathf.snapped(a, step)
  if step ~= 0 then
    return math.floor(a / step + 0.5) * step
  end
  return step
end

function mathf.fRandom(a, b)
  return a + love.math.random() * (b - a)
end

function mathf.setBitTo(n, b, t)
  local x = t and 1 or 0
  -- (n & ~(1 << n)) | (x << n)
  return bit.bor(bit.band(n, bit.bnot(bit.lshift(1, n))), bit.lshift(x, n))
end

function mathf.setBitTo1(n, b)
  -- n | (1 << b)
  return bit.bor(n, bit.lshift(1, b))
end

function mathf.setBitTo0(n, b)
  -- n & ~(1 << b)
  return bit.band(n, bit.bnot(bit.lshift(1, b)))
end

function mathf.getBit(n, b)
  -- (n >> b) & 1 ~= 0
  return bit.band(bit.rshift(n, b), 1) ~= 0
end

return mathf
