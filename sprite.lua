local class = require("class")
local loadAse = require("ase")

local blendmodes = {
  [0] = "alpha",
  [1] = "multiply",
  [2] = "screen",
  [4] = "darken",
  [5] = "lighten",
  [16] = "add",
  [17] = "subtract",
}

local Sprite = class()

function Sprite:init(path)
  self.offsetx = 0
  self.offsety = 0

  self.currentFrame = 1
  self.animTime = 0

  self.layers = {}
  self.frames = {}
  self.tags = {}

  if path:match("%.ase$") then -- This is an aseprite file
    local file = loadAse(path)

    self.width = file.header.width
    self.height = file.header.height

    for _, frame in ipairs(file.header.frames) do
      for _, chunk in ipairs(frame.chunks) do
        if chunk.type == 0x2004 then
          local layerdat = chunk.data
          if layerdat.type == 0 then
            local layer = {}
            local flags = layerdat.flags

            layer.visible = bit.band(flags, 1) ~= 0
            layer.blend = blendmodes[layerdat.blend]
            if not layer.blend then
              error("Unsupported blend mode.", 1)
            end
            layer.alpha = 1 - layerdat.opacity / 255

            table.insert(self.layers, layer)
          end
        elseif chunk.type == 0x2005 then -- Image
          local cel = chunk.data
          local buf = love.data.decompress("data", "zlib", cel.data)
          local imageData = love.image.newImageData(
            cel.width, cel.height, "rgba8", buf)
          local image = love.graphics.newImage(imageData)
          local canvas = love.graphics.newCanvas(self.width, self.height)

          love.graphics.setCanvas(canvas)
          love.graphics.draw(image, cel.x, cel.y)
          love.graphics.setCanvas()

          table.insert(self.frames, {
            image = canvas,
            duration = frame.frame_duration / 1000
          })

          image:release()
          imageData:release()
        elseif chunk.type == 0x2018 then
          for i, tag in ipairs(chunk.data.tags) do
            if i == 1 then
              self.activeTag = tag.name
            end

            self.tags[tag.name] = {
              from = tag.from + 1,
              to = tag.to + 1,
              framec = tag.to - tag.from,
            }
          end
        end
      end
    end
  else -- Other file format
    local image = love.graphics.newImage(path)
    self.width = image:getWidth()
    self.height = image:getHeight()

    table.insert(self.layers, {
      visible = true,
      blend = "alpha",
      alpha = 1
    })

    table.insert(self.frames, {
      image = image,
      duration = 0.1,
    })
  end
end

function Sprite:alignedOffset(x, y)
  if x == "left" then
    self.offsetx = 0
  elseif x == "center" then
    self.offsetx = self.width / 2
  elseif x == "right" then
    self.offsetx = self.width
  end

  if y == "top" then
    self.offsety = 0
  elseif y == "center" then
    self.offsety = self.height / 2
  elseif y == "bottom" then
    self.offsety = self.height
  end
end

function Sprite:setActiveTag(name, preserveFrame)
  if name and not self.tags[name] then
    error("No tag named '" .. name .. "'", 1)
  end

  -- Try to keep the same relative frame in the new animation
  if preserveFrame then
    local tag = self.tags[self.activeTag]
    local dist = self.currentFrame - tag.from

    local new = self.tags[name]
    self.currentFrame = new.from + (dist % new.framec)
  end

  self.activeTag = name
end

function Sprite:animate(speedMod)
  speedMod = speedMod or 1

  local dt = love.timer.getDelta()

  local from = 1
  local to = #self.frames
  local frame = self.frames[self.currentFrame]

  if self.activeTag then
    from = self.tags[self.activeTag].from
    to = self.tags[self.activeTag].to
  end

  self.animTime = self.animTime + dt
  if self.animTime > frame.duration * speedMod then
    self.animTime = 0
    self.currentFrame = self.currentFrame + 1
  end

  if self.currentFrame < from or self.currentFrame > to then
    self.currentFrame = from
  end
end

function Sprite:draw(x, y, r, sx, sy, kx, ky)
  local layerc = #self.layers
  local start = self.currentFrame * layerc - 1

  sx = sx or 1
  sy = sy or sx
  kx = kx or 0
  ky = ky or 0

  for i=1, layerc do
    local offset = i
    local layer = self.layers[i]
    if layer.visible then
      love.graphics.setBlendMode(layer.blend)
      love.graphics.draw(
        self.frames[start + offset].image,
        math.floor(x), math.floor(y),
        r, sx, sy, self.offsetx, self.offsety, kx, ky)
      love.graphics.setBlendMode("alpha")
    end
  end
end

return Sprite
