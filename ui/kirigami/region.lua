
--[[
Kirigami Library
https://github.com/pakeke-constructor/Kirigami

MIT LICENSE
Copyright (c) Oliver Garrett (pakeke-constructor)
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local Region = {}
local Region_mt = {__index = Region}



local function getXYWH(x,y,w,h)
    -- allows for passing in a region as first argument.
    -- if a region is passed in, takes x,y,w,h from the region.
    if type(x) == "number" then
        return x,y,w,h
    else
        assert(type(x) == "table", "Expected x,y,w,h numbers")
        local region = x
        return region:get()
    end
end


local function max0(v)
    return math.max(v,0)
end

local function getWH(w,h)
    -- allows for passing in a region as first argument.
    -- if a region is passed in, takes w,h from the region.
    if type(w) == "number" then
        return max0(w), max0(h)
    else
        assert(type(w) == "table", "Expected w,h numbers")
        local region = w
        local _,_, ww,hh = region:get()
        return ww,hh
    end
end



local function newRegion(x,y,w,h)
    if not x then
        -- default region is empty
        x,y,w,h = 0,0,0,0
    end
    x,y,w,h = getXYWH(x,y,w,h)
    return setmetatable({
        x = x,
        y = y,
        w = math.max(w, 0),
        h = math.max(h, 0)
    }, Region_mt)
end



local unpack = unpack or table.unpack
-- other lua version compat ^^^






local function getRatios(...)
    -- gets ratios from a vararg-list of numbers
    local ratios = {...}
    local len = #ratios
    local sum = 0
    if len <= 0 then
        error("No numbers passed in!")
    end

	for _, v in ipairs(ratios) do
        -- collect ratios
        assert(type(v) == "number", "Arguments need to be numbers")
        sum = sum + v
	end

    for i=1, len do
        -- normalize region ratios:
        ratios[i] = ratios[i] / sum
    end
    return ratios
end

function Region:splitVertical(...)
    --[[
        splits a region vertically.
        For example:  

        region:splitVertical(0.1, 0.9)

        This code ^^^ splits a region into two horizontally-lying
        rectangles; one at the top, taking up 10%, and one at bottom taking 90%.
    ]]
    local regions = getRatios(...)
    local accumY = self.y
    for i=1, #regions do
        local ratio = regions[i]
        local y, h = accumY, self.h*ratio
        regions[i] = newRegion(self.x, y, self.w, h)
        accumY = accumY + h
    end
    return unpack(regions)
end


function Region:splitHorizontal(...)
    --[[
        Same as vertical, but in other direction
    ]]
    local regions = getRatios(...)
    -- 0.1  0.8  0.1
    -- |.|........|.|
    local accumX = self.x
    for i=1, #regions do
        local ratio = regions[i]
        local x, w = accumX, self.w*ratio
        regions[i] = newRegion(x, self.y, w, self.h)
        accumX = accumX + w
    end
    return unpack(regions)
end




function Region:grid(rows, cols)
    local w, h = self.w/rows, self.h/cols
    local regions = {}

    for ix=0, rows-1 do
        for iy=0, cols-1 do
            local x = self.x + w*ix
            local y = self.y + h*iy
            local r = newRegion(x,y,w,h)
            table.insert(regions, r)
        end
    end

    return regions
end


function Region:rows(rows)
  return self:grid(rows, 1)
end


function Region:columns(columns)
  return self:grid(1, columns)
end

function Region:fillWith(other)
  return self:grid(
    math.floor(self.w / other.w),
    math.floor(self.h / other.h))
end


function Region:ninePatch(other)
  local endx = self.x + self.w
  local oendx = other.x + other.w
  local endy = self.y + self.h
  local oendy = other.y + other.h

  local left   = newRegion(self.x, other.y, other.x - self.x, other.h)
  local right  = newRegion(oendx, other.y, endx - oendx, other.h)
  local top    = newRegion(other.x, self.y, other.w, other.y - self.y)
  local bottom = newRegion(other.x, oendy, other.w, endy - oendy)

  local tl = newRegion(self.x, self.y, other.x - self.x, other.y - self.y)
  local tr = newRegion(oendx, self.y, endx - oendx, other.y - self.y)
  local bl = newRegion(self.x, oendy, other.x - self.x, endy - oendy)
  local br = newRegion(oendx, oendy, endx - oendx, endy - oendy)

  return left, right, top, bottom, tl, tr, bl, br
end

local function pad(self, top, left, bot, right)
    local dw = left + right
    local dh = top + bot

    return newRegion(
        self.x + left,
        self.y + top,
        self.w - dw,
        self.h - dh
    )
end

function Region:padPixels(left, top, right, bot)
    --[[
        Creates an inner region, with padding on sides.

        :pad(v) -- pads all sides by v.
        :pad(a,b) -- pads  by `a`, and y-sides by `b`.
        :pad(top,left,bot,right) -- pads all sides independently
    ]]
    assert(type(left) == "number", "need a number for padding")
    top = top or left -- If top not specified, defaults to left.
    bot = bot or top -- defaults to top
    right = right or left -- defaults to left
    return pad(self, top, left, bot, right)
end



local function maxHalf(x)
    return math.min(0.5, x)
end


function Region:pad(left, top, right, bot)
    --[[
        Pads a region, percentage wise.
        For example, :pad(0.1) will give 10% padding to ALL sides.
    ]]
    assert(type(left) == "number", "need a number for padding")
    left = maxHalf(left)
    top = maxHalf(top or left)
    bot = maxHalf(bot or top)
    right = maxHalf(right or left)

    local w,h = self.w, self.h
    left, right = left*w, right*w
    top, bot = top*h, bot*h

    return pad(self, top, left, bot, right)
end


function Region:growTo(width, height)
    --[[
        grows a region to width/height
    ]]
    width, height = getWH(width, height)
    local w = math.max(width, self.w)
    local h = math.max(height, self.h)
    if w ~= self.w or h ~= self.h then
        return newRegion(self.x,self.y, w,h)
    end
    return self
end


function Region:shrinkTo(width, height)
    --[[
        shrinks a region to width/height
    ]]
    width, height = getWH(width, height)
    local w = math.min(width, self.w)
    local h = math.min(height, self.h)
    if w ~= self.w or h ~= self.h then
        return newRegion(self.x,self.y, w,h)
    end
    return self
end



function Region:getScaleToFit(width, height)
    --[[
        gets the scale such that a region fits (width, height) bounds.
    ]]
    width, height = getWH(width, height)
    local w, h = self.w, self.h
    local scaleX = width / w
    local scaleY = height / h

    -- we scale by the smallest value.
    -- this ensures that the result fits within the bounds
    local scale = math.min(scaleX, scaleY)
    return scale
end



function Region:scaleToFit(width, height)
    local scale = self:getScaleToFit(width, height)
    local w, h = self.w, self.h
    return newRegion(self.x, self.y, w*scale, h*scale)
end

function Region:scale(sx, sy)
    sx = sx or 1
    sy = sy or 1
    return newRegion(self.x, self.y, self.w*sx, self.h*sy)
end


function Region:set(x,y,w,h)
    return newRegion(
        x or self.x,
        y or self.y,
        w or self.w,
        h or self.h
    )
end




function Region:centerX(other)
    --[[
        centers a region horizontally w.r.t other
    ]]
    local targX, _ = self:getCenter()
    local currX, _ = other:getCenter()
    local dx = currX - targX
    
    return newRegion(self.x+dx, self.y, self.w, self.h)
end


function Region:centerY(other)
    --[[
        centers a region vertically w.r.t other
    ]]
    local _, targY = self:getCenter()
    local _, currY = other:getCenter()
    local dy = currY - targY
    
    return newRegion(self.x, self.y+dy, self.w, self.h)
end


function Region:center(other)
    return self
        :centerX(other)
        :centerY(other)
end


local function isDifferent(self, x,y,w,h)
    -- check for efficiency reasons
    return self.x ~= x
        or self.y ~= y
        or self.w ~= w
        or self.h ~= h
end


local function getEnd(self)
    return self.x+self.w, self.y+self.h
end


function Region:intersection(other)
    --[[
        Intersects 2 regions.
        opposite of `union`
    
        :intersection is useful for putting a MAXIMUM on region size
    ]]
    local x,y,endX,endY
    x = math.max(other.x, self.x)
    y = math.max(other.y, self.y)
    endX, endY = getEnd(self)
    local endX2, endY2 = getEnd(other)
    endX = math.min(endX, endX2)
    endY = math.min(endY, endY2)
    local w, h = math.max(0,endX-x), math.max(endY-y,0)

    if isDifferent(self, x,y,w,h) then
        return newRegion(x,y,w,h)
    end
    return self
end


function Region:union(other)
    --[[
        Takes the union between 2 regions
        opposite of `intersection`

        :union is useful for putting a MINIMUM on region size.
    ]]
    local x,y,endX,endY
    x = math.min(other.x, self.x)
    y = math.min(other.y, self.y)
    endX, endY = getEnd(self)
    local endX2, endY2 = getEnd(other)
    endX = math.max(endX, endX2)
    endY = math.max(endY, endY2)
    local w, h = math.max(0,endX-x), math.max(endY-y,0)

    if isDifferent(self, x,y,w,h) then
        return newRegion(x,y,w,h)
    end
    return self
end


function Region:clampInside(other)
    --[[
        moves a region position such that it resides
        inside of `other`.
        Does not change the w,h values.
    ]]
    local x,y
    x, y = self.x, self.y
    local endX2, endY2 = getEnd(other)
    x = math.min(x, endX2 - self.w)
    y = math.min(y, endY2 - self.h)
    x = math.max(other.x, x)
    y = math.max(other.y, y)
    return newRegion(x,y,self.w,self.h)
end







function Region:offset(ox, oy)
    ox = ox or 0
    oy = oy or 0
    if ox ~= 0 or oy ~= 0 then
        return newRegion(self.x+ox, self.y+oy, self.w, self.h)
    end
    return self
end






function Region:exists()
    -- returns true if a region exists
    -- (ie its height and width are > 0)
    return self.w > 0 and self.h > 0 
end



function Region:getCenter()
    -- returns (x,y) position of center of region
    return (self.x + self.w/2), (self.y + self.h/2)
end


function Region:get()
    return self.x,self.y, self.w,self.h
end


return newRegion

