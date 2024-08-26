Tilemap = struct()

function Tilemap:new(map_data, image, tile_width, tile_height, collisions)
  self.tags = {"tilemap"}

  self.image = image
  self.batch = love.graphics.newSpriteBatch(image)
  self.data = map_data

  self.collisions = collisions

  self.tile_width = tile_width
  self.tile_height = tile_height

  self:initTileset()
  self:regenerateSpriteBatch()
end

function Tilemap:initTileset()
  self.quads = {}

  local tw, th = self.tile_width, self.tile_height
  local iw, ih = self.image:getDimensions()
  local x_tiles, y_tiles = iw / tw, ih / th

  if math.floor(x_tiles) ~= x_tiles or math.floor(y_tiles) ~= y_tiles then
    error("Cannot evenly divide image into tiles.")
  end

  for bitmap=1, x_tiles * y_tiles do
    local x, y = (bitmap - 1) % x_tiles, math.floor((bitmap - 1) / x_tiles)
    self.quads[bitmap] = love.graphics.newQuad(x * tw, y * th, tw, th, iw, ih)
  end
end

function Tilemap:getQuadForCell(x, y)
  if x + 1 > #self.data or x - 1 < 1
  or y + 1 > #self.data[x] or y - 1 < 1 then
    return 16
  end
end

function Tilemap:autotile(x, y)
  local u = self.data[x][y-1] ~= 0
  local r = self.data[x+1][y] ~= 0
  local d = self.data[x][y+1] ~= 0
  local l = self.data[x-1][y] ~= 0

  local ur = self.data[x+1][y-1] ~= 0
  local ul = self.data[x-1][y-1] ~= 0
  local dr = self.data[x+1][y+1] ~= 0
  local dl = self.data[x-1][y+1] ~= 0

  local quad_idx = 0

  if ul and u and l then quad_idx = quad_idx + 1 end
  if ur and u and r then quad_idx = quad_idx + 2 end
  if dr and d and r then quad_idx = quad_idx + 4 end
  if dl and d and l then quad_idx = quad_idx + 8 end

  if quad_idx ~= 0 then
    self.batch:add(self.quads[quad_idx], x * self.tile_width, y * self.tile_height)
  end

  return quad_idx
end

function Tilemap:isPointOnTile(x, y)
  local mx = math.floor(x / self.tile_width)
  local my = math.floor(y / self.tile_height - 0.5)

  if mx + 1 > #self.data or mx - 1 < 1
  or my + 1 > #self.data[mx] or my - 1 < 1 then
    return true
  end

  return self.data[mx][my] ~= 0
end

function Tilemap:regenerateSpriteBatch()
  self.batch:clear()

  for x=2, #self.data-1 do
    for y=2, #self.data[x]-1 do
      local cell = self.data[x][y]
      if cell ~= 0 then
        local idx = self:autotile(x, y)
        local coll_shape = self.collisions[idx]
        if coll_shape then
          local coll = {x=x*self.tile_width, y=y*self.tile_height, tags={"env"}}
          coll.body = Body.create(coll, coll_shape)
          world.add(coll)
        end
      end
    end
  end
end

function Tilemap:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.batch)
end
