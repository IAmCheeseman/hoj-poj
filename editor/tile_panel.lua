local lui = require("editor.lui")
local kg = require("editor.kirigami")
local ui = require("editor.ui")
local data = require("editor.data")
local Sprite = require("sprite")

local RadioButton = require("editor.radio_button")
local TileSelector = require("editor.tile_selector")

local TilePanel = lui.Element()

function TilePanel:init()
  self.type = "TilePanel"
  self.maxnamelen = 10
  self.maxtabs = 5

  local ontsclick = function(btn)
    self.selected = btn.index

    local tab = self.tabs[btn.index]
    self.tileselec.tsid = tab.tsid
    self.tileselec.sprite = tab.sprite
  end

  self.tileselec = TileSelector()
  self:addChild(self.tileselec)

  local tsids = data.getTilesetIds()
  self.selected = 1
  self.tabs = {}
  for i=1, self.maxtabs do
    local tsid = tsids[i]
    if not tsid then
      break
    end

    local tileset = data.getTileset(tsid)
    local radio = RadioButton(tileset.name, ontsclick)
    radio.index = i

    self:addChild(radio)
    local sprite = Sprite(tileset.image)

    table.insert(self.tabs, {
      tsid = tsid,
      radio = radio,
      sprite = sprite,
    })

    if i == 1 then
      radio.selected = true
      ontsclick(radio)
    end
  end
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

  local rows = tabsr:rows(self.maxtabs)
  for i=1, self.maxtabs do
    local tabr = rows[i]
    local tab = self.tabs[i]

    if not tab then
      break
    end

    tabr = tabr:padPixels(ui.padding, 0)
    tab.radio:render(tabr:get())
  end

  self.tileselec:render(contentr:get())
end

return TilePanel
