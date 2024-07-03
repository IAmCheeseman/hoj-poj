local lui = require("editor.lui")
local kg = require("editor.kirigami")
local ui = require("editor.ui")

local Panel = require("editor.panel")
local MapPanel = require("editor.map_panel")

local Menu = lui.Element()

function Menu:init()
  self.type = "Menu"

  self.mappanel = MapPanel()
  self:addChild(self.mappanel)

  self.panel = Panel()
  self:addChild(self.panel)
end

function Menu:onRender(x, y, w, h)
  local r = kg.Region(x, y, w, h)
  local mp, _, p = r:splitVertical(0.05, 0.6, 0.35)

  self.mappanel:render(mp:get())
  self.panel:render(p:get())
end

return Menu
