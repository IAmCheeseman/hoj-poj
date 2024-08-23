local mods = {}
local mod_dir = "mods"

local modding = {}

function modding.loadMods()
  local items = love.filesystem.getDirectoryItems(mod_dir)
  for _, item in ipairs(items) do
    local path = mod_dir .. "/" .. item
    local info = love.filesystem.getInfo(path)
    if info then

      if info.type == "file" then
        if path:match("%.lua$") then
          local chunk, err = love.filesystem.load(path)
          if err then
            print(err)
          else
            mods[path] = chunk()
            try(mods[path].init)
            print("Loaded mod '" .. path .. "'")
          end
        end
      end

    end
  end
end

function modding.step()
  for _, mod in pairs(mods) do
    try(mod.step)
  end
end

function modding.postStep()
  for _, mod in pairs(mods) do
    try(mod.postStep)
  end
end

return modding
