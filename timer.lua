local max_time = 30 * max_fps
local timer = max_time

local kill_worth = 0.2

function stepKillTimer()
  timer = timer - 1
end

function addToKillTimer()
  timer = timer + kill_worth * getCombo()
end

function getKillTimer()
  return math.max(math.floor(timer / max_fps), 0)
end
