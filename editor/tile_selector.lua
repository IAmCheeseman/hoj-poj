local lui = require("editor.lui")
local kg = require("editor.kirigami")
local ui = require("editor.ui")
local data = require("editor.data")
local Sprite = require("sprite")

local TileSelector = lui.Element()

function TileSelector:init()
  self.mx, self.my = 0, 0

  self.selsx, self.selsy = 0, 0
  self.selex, self.seley = 0, 0
end

function TileSelector:isInBounds(px, py)
  local x, y, w, h = self:getView()
  return px > x and py > y and px < x + w and py < y + h
end

function TileSelector:onMousePress(mx, my, button, _, _)
  if button == 1 and self:isInBounds(mx, my) then
    self.selsx = mx
    self.selsy = my

    self.selex = mx
    self.seley = my
  end
end

function TileSelector:onMouseRelease(mx, my, button, _)
  if button == 1 and self:isInBounds(mx, my) then
    self.selex = mx
    self.seley = my
  end
end

function TileSelector:onRender(x, y, w, h)
  if not self.tsid then
    return
  end

  local r = kg.Region(x, y, w, h)

  local tileset = data.getTileset(self.tsid)
  local sw, sh = self.sprite.width, self.sprite.height
  local rectx, recty = sw / tileset.tilewidth,
                       sh / tileset.tileheight

  local scale = kg.Region(0, 0, sw, sh)
    :getScaleToFit(r.w, r.h)
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(r.x, r.y, 0, scale)
  for gx=0, rectx-1 do
    for gy=0, recty-1 do
      local dw = tileset.tilewidth * scale
      local dh = tileset.tileheight * scale
      local dx = r.x + gx * dw
      local dy = r.y + gy * dh
      ui.rectangle(ui.olcol, "line", dx, dy, dw, dh)
    end
  end

  local tw, th = tileset.tilewidth, tileset.tileheight
  local selsx = math.floor((self.selsx - r.x) / scale) * scale
  local selsy = math.floor((self.selsy - r.y) / scale) * scale
  local selex = math.floor((self.selex - r.x) / scale) * scale
  local seley = math.floor((self.seley - r.y) / scale) * scale
  print(selsx, selsy, selex, seley)

  local selx, sely = selsx * tw, self.selsy * th
  local selw, selh = (selex - selsx) * tw, (seley - selsy) * th
  print("\t", selw, selh)

  ui.rectangle(
    {1, 0.2, 0.5, 0.5}, "fill",
    selx * scale, sely * scale,
    selw * scale, selh * scale)
end

return TileSelector
