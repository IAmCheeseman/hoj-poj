local log = {}

local function msg(...)
  print(...)
end

function log.info(...)
  msg("[INFO]", ...)
end

function log.error(...)
  msg("[ERROR]", ...)
end

function log.fatal(...)
  msg("[FATAL]", ...)
  error(...)
end

return log
