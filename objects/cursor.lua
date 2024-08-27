Cursor = struct()

local cursor_sprite = Sprite.create("assets/cursor.png")
cursor_sprite:offset("center", "center")

function Cursor:new()
  self.z_index = math.huge

  love.mouse.setVisible(false)
end

function Cursor:gui()
  local mx, my = getMousePosition()
  cursor_sprite:draw(mx, my)
end
