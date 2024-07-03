local lui = require("editor.lui")
local kg = require("editor.kirigami")
local ui = require("editor.ui")
local Sprite = require("sprite")

local ObjButton = lui.Element()

function ObjButton:init(obj)
  self.sprite = Sprite(obj.image)
  self.sprite:alignedOffset("center", "center")

  local text = obj.name
  local maxnamelen = 10
  if #text > maxnamelen then
    text = text:sub(1, maxnamelen - 3) .. "..."
  end

  self.text = text
end

function ObjButton:onRender(x, y, w, h)
  local r = kg.Region(x, y, w, h)
  local imager, namer = r:splitVertical(0.7, 0.3)

  local spriter = kg.Region(0, 0, self.sprite.width, self.sprite.height)
  local scale = spriter:getScaleToFit(imager.w, imager.h)

  ui.roundRectangle(ui.olcol, "line", ui.rounding, r:get())
  local cx, cy = imager:getCenter()
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(cx, cy, 0, scale)
  ui.text(ui.fgcol, ui.font, self.text, "center", namer:get())
end

return ObjButton
