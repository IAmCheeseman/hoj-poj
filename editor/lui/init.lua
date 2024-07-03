
local PATH = (...):gsub('%.init$', '')

local LUI = {}

LUI.Element = require(PATH .. ".ElementClass")

return LUI

