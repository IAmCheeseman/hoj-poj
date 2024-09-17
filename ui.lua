local font_str = " AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzÑñ0123456789.,:;!?/\\*[]+-"

local function bar(x, y, w, h, p, bg, fg)
  love.graphics.setColor(bg)
  love.graphics.rectangle("fill", x, y, w + 1, h + 1)

  love.graphics.setColor(fg)
  love.graphics.rectangle("fill", x, y, w * p, h)
end

return {
  hud_font = love.graphics.newImageFont("assets/font.png", font_str),
  bar = bar,
}
