local game = require("game")

local loaded

local helptext = [[
Usage:
  --help, -h
    Display this text.
]]

local function displayHelp(exitcode)
  print(helptext)
  os.exit(exitcode)
end

function love.load(args)
  for _, arg in ipairs(args) do
    if arg == "--help" or arg == "-h" then
      displayHelp(0)
    else
      print("Unknown arg '" .. arg .. "'")
      displayHelp(1)
    end
  end

  loaded = game
  loaded.load(args)
end

function love.update(dt)
  loaded.update(dt)
end

function love.draw()
  loaded.draw()
end
