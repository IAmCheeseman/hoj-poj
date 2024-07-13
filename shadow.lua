local class = require("class")
local mathf = require("mathf")

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
  love.graphics.draw(canvas)--mathf.frac(viewport.camx), mathf.frac(viewport.camy))
  love.graphics.pop()
end

function shadow.init(world, vp)
  viewport = vp
  local w, h = viewport:getSize()
  canvas = love.graphics.newCanvas(w + 1, h + 1)
  world:add(ShadowRenderer())
end

local function drawShadow(s)
  love.graphics.ellipse(
    "fill", math.floor(s.x), math.floor(s.y) + 0.5, s.width, 3/2, 10)
end

function shadow.queueDraw(spriteOrWidth, x, y, sx, sy)
  sx = sx or 1
  sy = sy or sx

  local width = 0
  if type(spriteOrWidth) == "table" then
    width = spriteOrWidth.width / 2 + 3
  elseif type(spriteOrWidth) == "number" then
    width = spriteOrWidth + 3
  end

  table.insert(queue, {
    width = width,
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
