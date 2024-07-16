local log = {}

local oldPrint = print

local function msg(...)
  oldPrint(...)
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

function print(...)
  log.info(...)
end

return log
