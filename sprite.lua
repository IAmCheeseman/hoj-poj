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

  self.currentframe = 1
  self.animtime = 0

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
          local imagedat = love.image.newImageData(
            cel.width, cel.height, "rgba8", buf)
          local image = love.graphics.newImage(imagedat)
          local canvas = love.graphics.newCanvas(self.width, self.height)

          love.graphics.setCanvas(canvas)
          love.graphics.draw(image, cel.x, cel.y)
          love.graphics.setCanvas()

          table.insert(self.frames, {
            image = canvas,
            duration = frame.frame_duration / 1000
          })

          image:release()
          imagedat:release()
        elseif chunk.type == 0x2018 then
          for i, tag in ipairs(chunk.data.tags) do
            if i == 1 then
              self.activetag = tag.name
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

function Sprite:setActiveTag(name, preserveframe)
  if name and not self.tags[name] then
    error("No tag named '" .. name .. "'", 1)
  end

  -- Try to keep the same relative frame in the new animation
  if preserveframe then
    local tag = self.tags[self.activetag]
    local dist = self.currentframe - tag.from

    local new = self.tags[name]
    self.currentframe = new.from + (dist % new.framec)
  end

  self.activetag = name
end

function Sprite:animate(speedmod)
  speedmod = speedmod or 1

  local dt = love.timer.getDelta()

  local from = 1
  local to = #self.frames
  local frame = self.frames[self.currentframe]

  if self.activetag then
    from = self.tags[self.activetag].from
    to = self.tags[self.activetag].to
  end

  self.animtime = self.animtime + dt
  if self.animtime > frame.duration * speedmod then
    self.animtime = 0
    self.currentframe = self.currentframe + 1
  end

  if self.currentframe < from or self.currentframe > to then
    self.currentframe = from
  end
end

function Sprite:draw(x, y, r, sx, sy, kx, ky)
  local layerc = #self.layers
  local start = self.currentframe * layerc - 1

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
