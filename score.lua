local combo = 1
local combo_timer = 0
local max_combo_time = 150

local score = 0

function addScore(amount, x, y)
  score = score + amount * combo

  combo_timer = combo_timer + 60

  if combo_timer >= max_combo_time then
    combo_timer = math.max(combo_timer % max_combo_time, max_combo_time / 2)
    combo = combo + 1
  end

  local te = TextEffect:create("+" .. tostring(amount * combo), x, y)
  world.add(te)
end

function stepCombo()
  combo_timer = math.max(combo_timer - 1, 0)
  if combo_timer <= 0 then
    combo = 1
  end
end

function getScore()
  return score
end

function getCombo()
  return combo
end

function getComboTime()
  return combo_timer, max_combo_time
end

