local max_time = 60 * 7
local timer = max_time

local kill_worth = 1

function stepKillTimer(dt)
  timer = timer - dt
end

function addToKillTimer()
  timer = math.min(timer + kill_worth * getCombo(), max_time)
end

function getKillTimer()
  return math.max(math.floor(timer), 0)
end
