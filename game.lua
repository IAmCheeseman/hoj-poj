local start = os.clock()
love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")

local core = require("core")
local input = require("input")
local shadow = require("shadow")
local DebugScreen = require("objects.debugscreen")
local TiledMap = require("tiled.map")
local autoload = require("autoload")

autoload("objects/")

input.addAction("walk_up",    "kb", "w")
input.addAction("walk_left",  "kb", "a")
input.addAction("walk_down",  "kb", "s")
input.addAction("walk_right", "kb", "d")

input.addAction("pickup_item", "kb", "e")
input.addAction("switch_weapon", "kb", "space")

input.addAction("use_item", "mouse", 1)
input.addAction("toggle_collisions", "kb", "f2")

local curriedShadowDraw = function(drawable, x, y, _, sx, sy)
  shadow.queueDrawGeneric(love.graphics.draw, drawable, x, y, sx, sy, true)
end

local map = TiledMap(core.mainViewport, "assets/maps/start.lua", {
  layer = function(layer, data)
    if data.properties.isShadow then
      layer.drawFunc = curriedShadowDraw
    end
  end
})
core.world:add(DebugScreen())

local game = {}

local drawCollisions = false

input.actionTriggered:on(function(action, _, isRepeat)
  if action == "toggle_collisions" and not isRepeat then
    drawCollisions = not drawCollisions
  end
end)

function game.load()
  local metaInfo = require("meta_info")

  core.log.info(
    "Initialized. Took "
    .. tostring(math.floor((os.clock() - start) * 1000 + 0.5)) .. " ms")

  core.log.info(metaInfo.name .. " " .. metaInfo.version.str)

  core.log.info("Operating System: " .. love.system.getOS())

  local name, version, vendor, device = love.graphics.getRendererInfo()
  core.log.info("Renderer name: " .. name)
  core.log.info("Renderer version: " .. version)
  core.log.info("Renderer deveice: " .. device)
  core.log.info("Renderer vendor: " .. vendor)
end

function game.update(dt)
  core.pWorld:update()
  core.update:call(dt)
  core.world:update()
  core.postUpdate:call(dt)
end

function game.draw()
  core.mainViewport:apply()
    -- love.graphics.clear(0, 0, 0)
    shadow.renderAll()

    map:draw()
    core.world:draw()
    if drawCollisions then
      core.pWorld:draw()
    end

    core.draw:call()

    love.graphics.setColor(1, 1, 1)
  core.mainViewport:stop()

  core.guiViewport:apply()
    love.graphics.clear(0, 0, 0, 0)
    core.world:drawGui()
    core.gui:call()
    love.graphics.setColor(1, 1, 1)
  core.guiViewport:stop()

  core.postDraw:call()

  love.graphics.setColor(1, 1, 1)
  core.mainViewport:draw()
  core.guiViewport:draw()
end

return game
