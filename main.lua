local start = os.clock()
jit.off()

total_time = 0

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")
require("util")

struct = require("struct")
viewport = require("viewport")
sound = require("sound")
world = require("world")
action = require("action")
vec = require("vec")
Body = require("physics")
shape = require("polygon_shapes")
Sprite = require("sprite")
camera = require("camera")
log = require("log")

require("translations")
require("kill_timer")
require("spawner")
require("ammo")

local loadDirectory = require("load_directory")
loadDirectory("objects")
loadDirectory("functions")
loadDirectory("weapons")
loadDirectory("states")
loadDirectory("rooms")

local modding = require("modding")
modding.loadMods()

action.define("reset", {{method="key", input="r"}})
action.define("next", {{method="key", input="n"}})

world.add(Cursor:create())
world.add(PauseScreen:create())
world.flush()

Forest:switch({new_run=true})

function love.load()
  local init_time_ms = math.floor((os.clock() - start) * 1000)
  log.info("Initialized. Took " .. init_time_ms .. "ms")
  log.info("Operating system: " .. love.system.getOS())
end

function love.update(dt)
  total_time = total_time + dt

  action.step()
  modding.step()

  world.update(dt)

  if not world.is_paused then
    stepKillTimer(dt)

    if action.isJustDown("reset") then
      Forest:switch({new_run=true})
    end
  end

  modding.postStep()
  camera.step(dt)

  world.flush()

  if action.isJustDown("next") then
    Forest:switch({new_run=false})
  end

  update_graphics = true
end

function love.draw()
  if update_graphics then
    update_graphics = false

    love.graphics.clear(0, 0, 0)
    world.draw()

    do
      local stats = love.graphics.getStats()
      love.graphics.push()
      love.graphics.origin()
      love.graphics.print("FPS: " .. love.timer.getFPS())
      love.graphics.print("Draw calls: " .. stats.drawcalls, 0, 8)
      love.graphics.pop()
    end
  end

  love.graphics.setColor(1, 1, 1)
  viewport.draw()
end

function love.quit()
  local data = love.graphics.readbackTexture(Sprite.atlas.canvas)
  data:encode("png", "atlas.png")
end
