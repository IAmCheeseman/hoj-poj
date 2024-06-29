local class = require("class")
local vec = require("vec")

local VecAnimPicker = class()

function VecAnimPicker:init(anims)
  self.anims = anims
end

function VecAnimPicker:pick(x, y)
  local picked = nil
  local closest = math.huge

  for _, anim in ipairs(self.anims) do
    local ax, ay = anim[2], anim[3]
    local dist = vec.distance(x, y, ax, ay)

    if dist < closest then
      closest = dist
      picked = anim
    end
  end

  if not picked then
    picked = self.anims[1]
  end

  return picked[1], unpack(picked[4])
end

return VecAnimPicker
