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

local function drawSlant(s)
  s.drawFunc(s.sprite, s.x, s.y, 0, s.sx, s.sy * -0.5, -0.5 * s.sx, 0)
end

local function drawNormal(s)
  s.drawFunc(s.sprite, s.x, s.y, 0, s.sx, s.sy)
end

function shadow.queueDraw(sprite, x, y, sx, sy, drawStraight)
  drawStraight = drawStraight or false
  sx = sx or 1
  sy = sy or sx
  table.insert(queue, {
    sprite = sprite,
    drawFunc = sprite.draw,
    drawStraight = drawStraight,
    x = x,
    y = y,
    sx = sx,
    sy = sy,
  })
end

function shadow.queueDrawGeneric(func, sprite, x, y, sx, sy, drawStraight)
  sx = sx or 1
  sy = sy or sx
  table.insert(queue, {
    sprite = sprite,
    drawFunc = func,
    drawStraight = drawStraight,
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
    if s.drawStraight then
      drawNormal(s)
    else
      drawSlant(s)
    end
  end

  queue = {}

  love.graphics.setCanvas(prev)
end

return shadow
