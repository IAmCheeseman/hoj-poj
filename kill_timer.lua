local max_time = 30 * max_fps
local timer = max_time

local kill_worth = 1 * max_fps

function stepKillTimer()
  timer = timer - 1
end

function addToKillTimer()
  timer = math.min(timer + kill_worth * getCombo(), max_time)
end

function getKillTimer()
  return math.max(math.floor(timer / max_fps), 0)
end
