local max_time = 60 * 7
local timer = max_time

function resetKillTimer()
  max_time = 60 * 7
  timer = max_time
end

function stepKillTimer(dt)
  timer = timer - dt
end

function getKillTimer()
  return math.max(math.floor(timer), 0)
end
