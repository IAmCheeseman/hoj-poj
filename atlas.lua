local class = require("class")

local SpriteAtlas = class()
local atlas

function SpriteAtlas:init(width, height)
  self.width = width
  self.height = height

  self.canvas = love.graphics.newCanvas(width, height)

  self.cache = {}
  self.paths = {}
  self.bin = {
    x = 0,
    y = 0,
    width = width,
    height = height,
  }
end

function SpriteAtlas.s_getMainAtlas()
  return atlas
end

function SpriteAtlas:m_findNode(root, width, height)
  if root.texture then
    return self:m_findNode(root.right, width, height)
        or self:m_findNode(root.down, width, height)
  elseif width <= root.width and height <= root.height then
    return root
  end

  return nil
end

function SpriteAtlas:m_split(node, texture, width, height)
  node.texture = texture

  node.right = {
    x = node.x + width,
    y = node.y,
    width = node.width - width,
    height = height
  }
  node.down = {
    x = node.x,
    y = node.y + height,
    width = node.width,
    height = node.height - height,
  }

  node.width = width
  node.height = height
  return node
end

function SpriteAtlas:getData(id)
  return self.cache[id]
end

function SpriteAtlas:newQuad(id, x, y, w, h)
  local c = self.cache[id]
  return love.graphics.newQuad(c.x + x, c.y + y, w, h, self.width, self.height)
end

function SpriteAtlas:addSprite(texture, quad, id)
  if self.paths[id] then
    return self.paths[id]
  end

  if type(texture) == "string" then
    texture = love.graphics.newImage(texture)
  end

  local width, height = texture:getDimensions()

  local node = self:m_findNode(self.bin, width, height)
  if not node then
    error("Cannot fit image in texture atlas.", 1)
  end

  self:m_split(node, texture, width, height)
  love.graphics.setCanvas(self.canvas)
  if quad then
    love.graphics.draw(texture, quad, node.x, node.y)
  else
    love.graphics.draw(texture, node.x, node.y)
  end
  love.graphics.setCanvas()

  local atlasquad = love.graphics.newQuad(
    node.x, node.y,
    width, height,
    self.width, self.height)

  local cacheId = #self.cache + 1
  self.cache[cacheId] = {
    quad = atlasquad,
    x = node.x,
    y = node.y,
    width = width,
    height = height,
  }

  self.paths[id] = cacheId
  return cacheId
end

function SpriteAtlas:draw(cacheid, quad, x, y, r, sx, sy, ox, oy, kx, ky)
  local cache = self.cache[cacheid]
  love.graphics.draw(self.canvas, quad or cache.quad, x, y, r, sx, sy, ox, oy, kx, ky)
end

function SpriteAtlas:m_drawNode(node)
  love.graphics.rectangle("line", node.x, node.y, node.width, node.height)
  if node.right then
    self:m_drawNode(node.right)
    self:m_drawNode(node.down)
  end
end

function SpriteAtlas:debugDraw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.canvas, 0, 0)
  love.graphics.setColor(1, 0, 0)
  love.graphics.setLineStyle("rough")
  self:m_drawNode(self.bin)
end

function SpriteAtlas:drawQuad(quad, x, y, r, sx, sy, ox, oy, kx, ky)
  love.graphics.draw(self.canvas, quad, x, y, r, sx, sy, ox, oy, kx, ky)
end

atlas = SpriteAtlas(1028, 1028)

return SpriteAtlas
