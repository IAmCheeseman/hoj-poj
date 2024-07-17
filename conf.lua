local metaInfo = require("meta_info")

function love.conf(t)
  t.window.title = metaInfo.name .. " " .. metaInfo.version.str
  t.window.icon = nil
  t.window.width = 320 * 3
  t.window.height = 180 * 3
  t.window.borderless = false
  t.window.resizable = true
  t.window.minwidth = 320 * 3
  t.window.minheight = 180 * 3
  t.window.fullscreen = false
  t.window.fullscreentype = "desktop"
  t.window.vsync = 1

  t.window.highdpi = false
  t.window.usedpiscale = false
end
