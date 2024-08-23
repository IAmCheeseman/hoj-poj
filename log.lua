local _print = print
local function logMsg(prefix, ...)
  _print(prefix, ...)
end

local log = {}

function log.info(...)
  logMsg("info:", ...)
end

function log.err(...)
  logMsg("err:", ...)
end

function log.warn(...)
  logMsg("err:", ...)
end

print = log.info

return log
