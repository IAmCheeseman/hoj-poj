local lui = require("editor.lui")
local kg = require("editor.kirigami")
local ui = require("editor.ui")
local data = require("editor.data")

local MapPanel = lui.Element()

function MapPanel:init()
  self.type = "MapPanel"
  self.maxnamelen = 10
  self.maxtabs = 4
end

function MapPanel:onRender(x, y, w, h)
  local r = kg.Region(x, y, w, h)
  local titler, tabsr = r:splitHorizontal(0.1, 0.9)

  ui.rectangle(ui.bgcol, "fill", r:get())
  ui.rectangle(ui.olcol, "line", r:get())

  ui.text(ui.fgcol, ui.font, "Maps", "center", titler:get())
  ui.rectangle(ui.olcol, "line", titler:get())

  local mapids = data.getMapIds()
  local rows = tabsr:rows(self.maxtabs)
  for i=1, self.maxtabs do
    local tabr = rows[i]

    if not mapids[i] then
      break
    end

    local map = data.getMap(mapids[i])
    tabr = tabr:padPixels(ui.padding, 0)
    ui.rectangle(ui.olcol, "line", tabr:get())

    local ttitler, exinfor = tabr:splitHorizontal(0.6, 0.4)
    local displayname = map.name
    if #displayname > self.maxnamelen then
      displayname = displayname:sub(1, self.maxnamelen - 3) .. "..."
    end
    ui.text(ui.fgcol, ui.font, displayname, "center", ttitler:get())

    local exinfo = ""
    if map.infinite then
      exinfo = "Infinite"
    else
      exinfo = ("%dx%d"):format(map.width, map.height)
    end
    ui.text(ui.unimpfgcol, ui.font, exinfo, "center", exinfor:get())
  end
end

return MapPanel
