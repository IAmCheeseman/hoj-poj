local settings = require("settings")
local camera = {}

local x, y = 0, 0
local ssx, ssy = 0, 0

local pri = 0
local freq = 0
local jumps = 0
local max_jumps = 0
local strength_max = 0
local strength_min = 0
local deteriorate = false

local timer = 0

function camera.setPos(cx, cy, dt)
  x = mathx.dtLerp(x, cx, 20, dt)
  y = mathx.dtLerp(y, cy, 20, dt)
end

function camera.shake(p, f, j, sma, smi, d)
  if p <= pri then
    return
  end

  pri = p
  freq = f
  jumps = j
  max_jumps = j
  strength_max = sma
  strength_min = smi
  deteriorate = d or false
end

local function jump(jx, jy)
  ssx = jx
  ssy = jy

  jumps = jumps - 1
  if jumps <= 0 then
    pri = 0
    strength_min = 0
    strength_max = 0
  else
    timer = freq
  end
end

function camera.jump(p, angle, strength)
  if p <= pri then
    return
  end

  ssx = math.cos(angle) * strength
  ssy = math.sin(angle) * strength
end

function camera.step(dt)
  ssx = mathx.dtLerp(ssx, 0, 20, dt)
  ssy = mathx.dtLerp(ssy, 0, 20, dt)

  timer = timer - dt
  if timer <= 0 and pri ~= 0 then
    local angle = mathx.frandom(0, mathx.tau)
    local strength = mathx.frandom(strength_min, strength_max)
    if deteriorate then
      local p = jumps / max_jumps
      strength = strength * p
    end
    strength = strength * settings.screenshake
    jump(math.cos(angle) * strength, math.sin(angle) * strength)
  end

  viewport.camx = x + ssx
  viewport.camy = y + ssy
end

return camera
