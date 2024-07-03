local game = require("game")
local editor = require("editor")

local loaded

local helptext = [[
Usage:
  --editor, -E
    Launch the editor.
  --help, -h
    Display this text.
]]

local function displayHelp(exitcode)
  print(helptext)
  os.exit(exitcode)
end

function love.load(args)
  local loadeditor = false
  for _, arg in ipairs(args) do
    if arg == "--editor" or arg == "-E" then
      loadeditor = true
    elseif arg == "--help" or arg == "-h" then
      displayHelp(0)
    else
      print("Unknown arg '" .. arg .. "'")
      displayHelp(1)
    end
  end

  if loadeditor then
    loaded = editor
  else
    loaded = game
  end

  loaded.load(args)
end

function love.update(dt)
  loaded.update(dt)
end

function love.draw()
  loaded.draw()
end
