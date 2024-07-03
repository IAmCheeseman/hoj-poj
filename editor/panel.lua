local lui = require("editor.lui")
local kg = require("editor.kirigami")
local ui = require("editor.ui")
local data = require("editor.data")

local LayerPanel = require("editor.layer_panel")
local TilePanel = require("editor.tile_panel")
local ObjPanel = require("editor.obj_panel")

local Panel = lui.Element()

function Panel:init()
  self.layerpanel = LayerPanel()
  self:addChild(self.layerpanel)

  self.tilepanel = TilePanel()
  self:addChild(self.tilepanel)

  self.objpanel = ObjPanel()
  self:addChild(self.objpanel)
end

function Panel:onRender(x, y, w, h)
  local r = kg.Region(x, y, w, h)
  local tor, lr = r:splitHorizontal(0.8, 0.2)

  self.layerpanel:render(lr:get())

  local selected = self.layerpanel.selectedlayer
  local layer = data.getLayer(selected)

  if layer.type == "object" then
    self.objpanel:render(tor:get())
  elseif layer.type == "tile" then
    self.tilepanel:render(tor:get())
  end
end

return Panel
