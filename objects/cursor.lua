Cursor = struct()

local cursor_sprite = Sprite.create("assets/cursor.png")
cursor_sprite:offset("center", "center")

function Cursor:new()
  self.persistent = true
  self.z_index = math.huge

  love.mouse.setVisible(false)
end

function Cursor:gui()
  love.graphics.setColor(0.5, 0.5, 0.5, 0.25)
  cursor_sprite:draw(getScreenPointerPosition())

  love.graphics.setColor(1, 1, 1)
  cursor_sprite:draw(getRealScreenPointerPosition())
end
