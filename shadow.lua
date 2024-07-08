local class = require("class")

local shadow = {}

shadow.zIndex = -1

local viewport
local canvas

local queue = {}

local ShadowRenderer = class()

function ShadowRenderer:init()
  self.persistent = true
end

function ShadowRenderer:update()
  self.zIndex = shadow.zIndex
end

function ShadowRenderer:draw()
  love.graphics.push()
  love.graphics.origin()
  love.graphics.setColor(0, 0, 0, 0.33)
  love.graphics.draw(canvas)
  love.graphics.pop()
end

function shadow.init(world, vp)
  viewport = vp
  canvas = love.graphics.newCanvas(viewport:getSize())
  world:add(ShadowRenderer())
end

local function drawShadow(s)
  love.graphics.ellipse(
    "fill", math.floor(s.x), math.floor(s.y), s.width, 2, 10)
end

function shadow.queueDraw(sprite, x, y, sx, sy)
  sx = sx or 1
  sy = sy or sx
  table.insert(queue, {
    width = sprite.width / 2 + 3,
    x = x,
    y = y,
    sx = sx,
    sy = sy,
  })
end

function shadow.renderAll()
  local prev = love.graphics.getCanvas()

  love.graphics.setCanvas(canvas)
  love.graphics.clear()

  love.graphics.setColor(0, 0, 0)
  for _, s in ipairs(queue) do
    drawShadow(s)
  end

  queue = {}

  love.graphics.setCanvas(prev)
end

return shadow
