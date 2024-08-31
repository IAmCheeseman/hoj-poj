local loadAse = require("ase")
local SpriteAtlas = require("sprite_atlas")

local chunk_layer_data = 0x2004
local chunk_img_data = 0x2005
local chunk_tag_data = 0x2018

local atlas = SpriteAtlas.create(1024, 1024)

local Sprite = {}
Sprite.__index = Sprite

function Sprite.create(path)
  local s = setmetatable({}, Sprite)

  s.offsetx = 0
  s.offsety = 0

  s.layers = {}
  s.frames = {}
  s.anims = {}

  s.timer = 0
  s.frame = 1
  s.is_playing = true
  s.is_over = false

  if path:match("%.ase$") then
    local file = loadAse(path)
    s.width = file.header.width
    s.height = file.header.height

    local frame_index = 1

    for _, frame in ipairs(file.header.frames) do
      for _, chunk in ipairs(frame.chunks) do
        if chunk.type == chunk_img_data then
          local cel = chunk.data
          local buf = love.data.decompress("data", "zlib", cel.data)
          local data = love.image.newImageData(cel.width, cel.height, "rgba8", buf)
          local img = love.graphics.newImage(data)
          local canvas = love.graphics.newCanvas(s.width, s.height)

          love.graphics.setCanvas(canvas)
          love.graphics.draw(img, cel.x, cel.y)
          love.graphics.setCanvas()

          local atlasId = atlas:addSprite(canvas, nil, path .. frame_index)
          frame_index = frame_index + 1

          table.insert(s.frames, {
            img = atlasId,--love.graphics.newImage(canvas:newImageData()),
            duration = frame.frame_duration / 1000,
          })

          img:release()
          data:release()
          canvas:release()
        elseif chunk.type == chunk_layer_data then
          local data = chunk.data
          if data.type == 0 then
            local layer = {}
            layer.visible = bit.band(data.flags, 1) ~= 0
            layer.a = 1 - data.opacity / 255

            table.insert(s.layers, layer)
            s.layers[data.name] = layer
          end
        elseif chunk.type == chunk_tag_data then
          for i, tag in ipairs(chunk.data.tags) do
            if i == 1 then
              s.active = tag.name
            end

            s.anims[tag.name] = {
              from = tag.from + 1,
              to = tag.to + 1,
            }
          end
        end
      end
    end

    love.graphics.setCanvas()
  else
    local img = love.graphics.newImage(path)
    local atlasId = atlas:addSprite(img, nil, path)

    table.insert(s.frames, {
      img = atlasId,
      duration = 1,
    })

    s.width, s.height = img:getDimensions()

    local layer = {}
    layer.visible = true
    layer.a = 1
    table.insert(s.layers, layer)
    s.layers["img"] = layer
  end

  return s
end

function Sprite:offset(x, y)
  if x == "left" then
    self.offsetx = 0
  elseif x == "center" then
    self.offsetx = math.ceil(self.width / 2)
  elseif x == "right" then
    self.offsetx = self.width
  elseif is(x, "number") then
    self.offsetx = x
  end

  if y == "top" then
    self.offsety = 0
  elseif y == "center" then
    self.offsety = math.ceil(self.height / 2)
  elseif y == "bottom" then
    self.offsety = self.height
  elseif is(y, "number") then
    self.offsety = y
  end

  return self
end

function Sprite:setAnimation(name)
  self.current_anim = name
end

function Sprite:isAtAnimationEnd()
  if not self.current_anim then
    return true
  end

  local anim = self.anims[self.current_anim]
  return self.frame == anim.to
end

function Sprite:update(dt, speed)
  speed = speed or 1

  if self.is_playing then
    local from = 1
    local to = #self.frames
    local frame = self.frames[self.frame]

    if self.current_anim then
      from = self.anims[self.current_anim].from
      to = self.anims[self.current_anim].to
    end

    self.timer = self.timer + dt * speed
    if self.timer >= frame.duration then
      self.timer = 0
      self.frame = self.frame + 1

      if self.frame > to then
        self.is_over = true
      end
    else
      self.is_over = false
    end

    if self.frame < from or self.frame > to then
      self.frame = from
    end
  end
end

function Sprite:draw(x, y, r, sx, sy, kx, ky)
  local layer_count = #self.layers
  local start = self.frame * layer_count - layer_count

  local i = 1
  repeat
    local offset = i
    local layer = self.layers[i]

    if layer.visible then
      atlas:draw(
        self.frames[start + offset].img, nil,
        math.floor(x), math.floor(y),
        r, sx, sy, self.offsetx, self.offsety, kx, ky)
    end

    i = i + 1
  until i > layer_count
end

return Sprite
