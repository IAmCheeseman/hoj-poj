local Room = {}
Room.__index = Room

function Room.create()
  local r = setmetatable({}, Room)
  return r
end

function Room:switch()
  world.clear()
  try(self.init, self)
end

return Room
