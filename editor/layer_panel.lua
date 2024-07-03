local lui = require("editor.lui")
local kg = require("editor.kirigami")
local ui = require("editor.ui")
local data = require("editor.data")

local RadioButton = require("editor.radio_button")

local LayerPanel = lui.Element()

function LayerPanel:init()
  self.type = "LayerPanel"
  self.layerbtn = {}
  self.selectedlayer = nil

  local onlayerclick = function(btn)
    self.selectedlayer = btn.layerid
  end

  local layerids = data.getLayerIds()
  for i, id in ipairs(layerids) do
    local layer = data.getLayer(id)
    local displayname = layer.name
    if layer.type == "object" then
      displayname = "(O) " .. displayname
    elseif layer.type == "tile" then
      displayname = "(T) " .. displayname
    elseif layer.type == "rect" then
      displayname = "(R) " .. displayname
    end

    local btn = RadioButton(displayname, onlayerclick)
    btn.layerid = id
    if i == 1 then
      btn.selected = true
      self.selectedlayer = id
    end
    table.insert(self.layerbtn, btn)
    self:addChild(btn)
  end
end

function LayerPanel:onRender(x, y, w, h)
  local r = kg.Region(x, y, w, h)
  local titler, contentr = r:splitVertical(0.1, 0.9)

  ui.rectangle(ui.bgcol, "fill", r:get())
  ui.rectangle(ui.olcol, "line", r:get())
  ui.rectangle(ui.olcol, "line", titler:get())
  ui.text(ui.fgcol, ui.font, "Layers", "center", titler:get())
  ui.rectangle(ui.olcol, "line", contentr:get())

  contentr = contentr:padPixels(ui.padding)
  local btns = contentr:shrinkTo(math.huge, ui.font:getHeight() * 2)
  local rows = contentr:fillWith(btns)
  for i, btn in ipairs(self.layerbtn) do
    local btnr = rows[i]
    btnr = btnr:padPixels(ui.padding)
    btn:render(btnr:get())
  end
end

return LayerPanel
