local core = require("core")
local lui = require("ui.lui")
local gui = require("gui")
local kg = require("ui.kirigami")
local items = require("item_init")
local style = require("ui.style")
local Sprite = require("sprite")

local Hud = lui.Element()

local heart = Sprite("assets/ui/heart.png")
local heartBg = Sprite("assets/ui/heart_bg.png")

function Hud:init(inventory, health)
  self.inventory = inventory
  self.health = health
end

function Hud:onRender(x, y, w, h)
  do -- Health
    local hpx = 3
    local hpy = h - 14

    do -- Heart
      love.graphics.setColor(1, 1, 1)
      heartBg:draw(hpx, hpy)
      love.graphics.setColor(1, 1, 1)

      local p = self.health.health / self.health.maxHealth
      local hh = math.ceil(heart.height * p)
      local diff = heart.height - hh
      local q = heart:quad(0, diff, heart.width, hh)
      heart:drawQuad(q, hpx, hpy + diff)
    end

    do -- Text
      love.graphics.setFont(style.font)
      local first = tostring(math.ceil(self.health.health))
      local second = ("/%d"):format(self.health.maxHealth)

      local dx = hpx + heart.width + 2
      local dy = hpy

      love.graphics.setColor(1, 1, 1)
      love.graphics.print(first, dx, dy)
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.print(second, dx + style.font:getWidth(first), dy)
    end
  end

  do -- Ammo
  end
end

return Hud
