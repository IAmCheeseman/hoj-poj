local input = require("input")
local mathf = require("mathf")

local camera = {}

input.addKeybind("movecam1", "kb", "lshift", "mouse", 1)
input.addKeybind("movecam2", "mouse", 3)

local minzoom = 1
local maxzoom = 5
local tzoom = 1

camera.x = 0
camera.y = 0
camera.w = 0
camera.h = 0
camera.zoom = 1

function camera.update()
  camera.w, camera.h = love.graphics.getDimensions()
  camera.zoom = mathf.dtLerp(camera.zoom, tzoom, 25)
end

function camera.apply()
  local tx = camera.x - camera.w * 0.5 / camera.zoom
  local ty = camera.y - camera.h * 0.5 / camera.zoom

  love.graphics.translate(-tx, -ty)
  love.graphics.scale(camera.zoom)
end

function camera.onMouseMoved(rx, ry)
  if input.isKeybindPressed("movecam1")
  or input.isKeybindPressed("movecam2") then
    camera.x = camera.x - rx
    camera.y = camera.y - ry
  end
end

function camera.onMouseWheelMoved(_, y)
  tzoom = tzoom + y
  tzoom = math.min(math.max(tzoom, minzoom), maxzoom)
end

input.mouseMoved:on(camera.onMouseMoved)
input.mouseWheelMoved:on(camera.onMouseWheelMoved)

return camera
