local log = {}

local loggingDirectory = "logs"
love.filesystem.createDirectory(loggingDirectory)

local date = os.date("*t")
local logFile = ("%s/%d-%d-%d_%d-%d.log"):format(
  loggingDirectory, date.year, date.month, date.day, date.hour, date.min)

love.filesystem.write(logFile, "")

local oldPrint = print

local function msg(...)
  local args = {...}
  local out = ""
  for _, v in ipairs(args) do
    out = out .. tostring(v) .. "\t"
  end
  oldPrint(...)
  local ok, error = love.filesystem.append(logFile, out .. "\n")
  if not ok then
    oldPrint(error)
  end
end

log.msg = msg

function log.info(...)
  msg("[INFO]", ...)
end

print = log.info

log.info("Log file " .. logFile)

function log.error(...)
  msg("[ERROR]", ...)
end

function log.warn(...)
  msg("[WARN]", ...)
end

local maxLogLifetime = 3600 * 24 * 5 -- 5 days

for _, file in ipairs(love.filesystem.getDirectoryItems(loggingDirectory)) do
  local path = loggingDirectory .. "/" .. file
  local info = love.filesystem.getInfo(path)
  if info then
    local time = info.modtime or 0
    local currentTime = os.time()
    if currentTime - time > maxLogLifetime then
      love.filesystem.remove(path)
      log.info("Removed log " .. path)
    end
  end

end


return log
