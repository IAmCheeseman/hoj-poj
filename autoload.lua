local function autoload(dir)
  local items = love.filesystem.getDirectoryItems(dir)
  for _, item in ipairs(items) do
    local path = dir .. item
    local info = love.filesystem.getInfo(path)
    if info then
      if info.type == "file" and item:match("%.lua$") then
        local chunk = love.filesystem.load(path)
        chunk()
      elseif info.type == "directory" then
        autoload(path)
      end
    end
  end
end

return autoload
