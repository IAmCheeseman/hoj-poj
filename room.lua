local Room = {}
Room.__index = Room

function Room.create()
  local r = setmetatable({}, Room)
  return r
end

function Room:switch(args)
  world.clear(args)
  try(self.init, self, args)
end

return Room
