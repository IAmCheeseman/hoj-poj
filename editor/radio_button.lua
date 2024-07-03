local lui = require("editor.lui")
local kg = require("editor.kirigami")
local ui = require("editor.ui")

local RadioButton = lui.Element()

function RadioButton:init(text, onclick)
  self.type = "RadioButton"
  self.text = text
  self.onclick = onclick
  self.selected = false
end

function RadioButton:onRender(x, y, w, h)
  local r = kg.Region(x, y, w, h)

  local circw = 32 / w
  local radio, text = r:splitHorizontal(circw, 1 - circw)
  ui.roundRectangle(ui.bgcol, "fill", ui.rounding, r:get())
  ui.roundRectangle(ui.olcol, "line", ui.rounding, r:get())
  local fill = self.selected and "fill" or "line"

  local col = self.selected and ui.foccol or ui.olcol
  ui.circle(col, fill, radio:padPixels(ui.padding):get())
  ui.text(col, ui.font, self.text, "left", text:get())
end

function RadioButton:onMousePress(...)
  local siblings = self:getParent():getChildren()
  for _, sibling in ipairs(siblings) do
    if sibling.type == "RadioButton" then
      sibling.selected = false
    end
  end

  if self.onclick then
    self:onclick(...)
  end
  self.selected = true
end

return RadioButton
