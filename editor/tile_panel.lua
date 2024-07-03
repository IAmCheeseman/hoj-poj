local lui = require("editor.lui")
local kg = require("editor.kirigami")
local ui = require("editor.ui")
local data = require("editor.data")
local Sprite = require("sprite")

local TilePanel = lui.Element()

function TilePanel:init()
  self.type = "TilePanel"
  self.maxnamelen = 10
  self.maxtabs = 5

  local tileset = data.getTileset("Brick")
  self.brick = Sprite(tileset.image)
end

function TilePanel:onRender(x, y, w, h)
  local r = kg.Region(x, y, w, h)
  local barr, contentr = r:splitVertical(0.1, 0.9)

  local titler, tabsr = barr:splitHorizontal(0.1, 0.9)

  ui.rectangle(ui.bgcol, "fill", r:get())
  ui.rectangle(ui.olcol, "line", r:get())

  ui.rectangle(ui.olcol, "line", titler:get())
  ui.text(ui.fgcol, ui.font, "Tiles", "center", titler:get())

  ui.rectangle(ui.olcol, "line", contentr:get())
  ui.rectangle(ui.olcol, "line", barr:get())

  local tsids = data.getTilesetIds()
  local rows = tabsr:rows(self.maxtabs)
  for i=1, self.maxtabs do
    local tabr = rows[i]

    if not tsids[i] then
      break
    end

    local tileset = data.getTileset(tsids[i])
    tabr = tabr:padPixels(ui.padding, 0)
    ui.rectangle(ui.olcol, "line", tabr:get())

    local ttitler, exinfor = tabr:splitHorizontal(0.6, 0.4)
    local displayname = tileset.name
    if #displayname > self.maxnamelen then
      displayname = displayname:sub(1, self.maxnamelen - 3) .. "..."
    end
    ui.text(ui.fgcol, ui.font, displayname, "center", ttitler:get())

    local exinfo = ("%dx%d"):format(tileset.tilewidth, tileset.tileheight)
    ui.text(ui.unimpfgcol, ui.font, exinfo, "center", exinfor:get())
  end

  local tileset = data.getTileset("Brick")
  local rectx, recty = self.brick.width / tileset.tilewidth,
                       self.brick.height / tileset.tileheight

  local scale = kg.Region(0, 0, self.brick.width, self.brick.height)
    :getScaleToFit(contentr.w, contentr.h)
  love.graphics.setColor(1, 1, 1)
  self.brick:draw(contentr.x, contentr.y, 0, scale)
  for gx=0, rectx-1 do
    for gy=0, recty-1 do
      local dw = tileset.tilewidth * scale
      local dh = tileset.tileheight * scale
      local dx = contentr.x + gx * dw
      local dy = contentr.y + gy * dh
      ui.rectangle(ui.olcol, "line", dx, dy, dw, dh)
    end
  end
end

return TilePanel
