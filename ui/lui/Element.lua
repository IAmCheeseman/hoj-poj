
local path = (...):gsub('%.[^%.]+$', '')

local util = require(path .. ".util")


local Element = {}


local function dispatchToChildren(self, funcName, ...)
    for _, child in ipairs(self:getChildren()) do
        if child:isActive() then
            child[funcName](child, ...)
        end
    end
end



local function forceDispatchToChildren(self, funcName, ...)
    for _, child in ipairs(self:getChildren()) do
        child[funcName](child, ...)
    end
end



function Element:getParent()
    return self._parent
end



function Element:setup()
    -- called on initialization
    self._childElementHash = {--[[
        [childElem] -> true
        for checking if we have an elem or not
    ]]}
    self._children = {}

    self._parent = false
    -- Parent of this element.
    -- Could be a Scene, or a parent Element

    self._view = {x=0,y=0,w=0,h=0} -- last seen view
    self._active = false
    self._hovered = false
    self._clickedOnBy = {--[[
        [button] -> true/false
        whether this element is being clicked on by a mouse button
    ]]}

    self._markedAsRoot = false
    -- if this is set to true, then we will accept this element as a "root".
    -- For example, a `Scene` is regarded as a root element.

    self._focusedChild = false
end


function Element:isRoot()
    -- element with no parent = root element
    return not self._parent
end


function Element:makeRoot()
    --[[
        Denotes this element as a "Root" element.
        This basically tells us that we can draw this element in a detatched fashion.

        (For example, a "Scene" is a good example of a "Root" element)
    ]]
    self._markedAsRoot = true
end



local function setParent(childElem, parent)
    if parent and childElem:getParent() then
        error("Element was already contained inside something else!")
    end
    assert(childElem ~= parent, "???")
    childElem._parent = parent
end




local function assertChildElemValid(elem)
   if type(elem) ~= "table" or (not elem.render) then
        error("not valid LUI element: " .. tostring(elem))
    end
    if elem._markedAsRoot then
        error("Cannot add an element that is marked as root!")
    end
end


function Element:addChild(childElem)
    if self:hasChild(childElem) then
        return --already has.
    end
    assertChildElemValid(childElem)
    table.insert(self._children, childElem)
    self._childElementHash[childElem] = true
    setParent(childElem, self)
    util.tryCall(self.onAddChild, self)
    return childElem
end


function Element:removeChild(childElem)
    if not self:hasChild(childElem) then
        return
    end
    util.listDelete(self._children, childElem)
    self._childElementHash[childElem] = nil
    setParent(childElem, nil)
    util.tryCall(self.onRemoveChild, self)
end


function Element:hasChild(childElem)
    return self._childElementHash[childElem]
end




local function setView(self, x,y,w,h)
    -- set the view
    local view = self._view
    view.x = x
    view.y = y
    view.w = w
    view.h = h
end


function Element:getView()
    local view = self._view
    return view.x,view.y,view.w,view.h
end


local function deactivateheirarchy(self)
    self._active = false
    for _, childElem in ipairs(self._children) do
        deactivateheirarchy(childElem)
    end
end

local function activate(self)
    self._active = true
end


function Element:startStencil(x,y,w,h)
    local function stencil()
        love.graphics.rectangle("fill",x,y,w,h)
    end
    love.graphics.stencil(stencil, "replace", 2)
    love.graphics.setStencilTest("greater", 1)
end


function Element:endStencil()
    love.graphics.setStencilTest()
end


function Element:render(x,y,w,h)
    if self:isRoot() and (not self._markedAsRoot) then
        error("Attempt to render uncontained element!", 2)
    end
    deactivateheirarchy(self)
    activate(self)

    util.tryCall(self.onRender, self, x,y,w,h)

    setView(self, x,y,w,h)
end



local function getCapturedChild(self, x, y)
    -- returns the child that is "captured" by position (x,y),
    -- (Or nil if there is none.)
    local children = self:getChildren()
    -- iterate backwards, because last child is the "top" child.
    for i=#children, 1, -1 do
        local child = children[i]
        if child:contains(x, y) and child:isActive() then
            return child
        end
    end
end



function Element:mousepressed(mx, my, button, istouch, presses)
    -- should be called when mouse clicks on this element
    if not self:contains(mx,my) then
        return false
    end
    util.tryCall(self.onMousePress, self, mx, my, button, istouch, presses)
    self._clickedOnBy[button] = true

    local child = getCapturedChild(self, mx, my)
    if child then
        child:mousepressed(mx, my, button, istouch, presses)
    end
    return true -- consumed!
end


function Element:mousereleased(mx, my, button, istouch, presses)
    -- should be called when mouse is released ANYWHERE in the scene
    if not self._clickedOnBy[button] then
        return -- This event doesn't concern this element
    end
    
    util.tryCall(self.onMouseRelease, self, mx, my, button, istouch, presses)
    self._clickedOnBy[button] = false

    forceDispatchToChildren(self, "mousereleased", mx, my, button, istouch, presses)
end





local function endHover(self, mx, my)
    util.tryCall(self.onEndHover, self, mx, my)
    self._hovered = false
end


local function startHover(self, mx, my)
    util.tryCall(self.onStartHover, self, mx, my)
    self._hovered = true
end

local function updateHover(self, mx, my)
    if self._hovered then
        if not self:contains(mx,my) then
            -- then its no longer hovering!
            endHover(self, mx, my)
        end
    end
end



function Element:mousemoved(mx, my, dx, dy, istouch)
    util.tryCall(self.onMouseMoved, self, mx, my, dx, dy, istouch)

    updateHover(self, mx, my)
    for _,child in ipairs(self:getChildren()) do
        updateHover(child, mx, my)
    end

    local child = getCapturedChild(self, mx, my)
    if child then
        startHover(child, mx, my)
    end

    dispatchToChildren(self, "mousemoved", mx, my, dx, dy, istouch)
end


function Element:wheelmoved(dx,dy)
    if self:isHovered() then
        util.tryCall(self.onWheelMoved, self, dx, dy)
        dispatchToChildren(self, "wheelmoved", dx, dy)
    end
end



function Element:keypressed(key, scancode, isrepeat)
    util.tryCall(self.onKeyPress, self, key, scancode, isrepeat)
    dispatchToChildren(self, "keypressed", key, scancode, isrepeat)
end


function Element:keyreleased(key, scancode)
    util.tryCall(self.onKeyRelease, self, key, scancode)
    dispatchToChildren(self, "keyreleased", key, scancode)
end


function Element:textinput(text)
    util.tryCall(self.onTextInput, self, text)
    dispatchToChildren(self, "textinput", text)
end


function Element:resize(x,y)
    util.tryCall(self.onResize, self, x, y)
    dispatchToChildren(self, "resize", x, y)
end




function Element:getParent()
    return self._parent
end


function Element:getChildren()
    return self._children
end


local function maxDepthError()
    error("max depth reached in element heirarchy (Element is a child of itself?)")
end


local MAX_DEPTH = 10000

function Element:getRoot()
    -- gets the root ancestor of this element
    local elem = self
    for _=1,MAX_DEPTH do
        local parent = elem:getParent()
        if parent then
            elem = parent
        else
            return elem -- its the root!
        end
    end
    maxDepthError()
end





local function setFocusedChild(self, childElem)
    self._focusedChild = childElem
end



function Element:focus()
    if self:isFocused() then
        return
    end

    util.tryCall(self.onFocus, self)
    local root = self:getRoot()
    if root then
        setFocusedChild(root, self)
    end
end



function Element:unfocus()
    if not self:isFocused() then
        return
    end

    util.tryCall(self.onUnfocus, self)
    local root = self:getRoot()
    if root then
        setFocusedChild(root, nil)
    end
end


function Element:isFocused()
    local root = self:getRoot()
    return root:getFocusedChild() == self
end


function Element:getFocusedChild()
    return self._focusedChild
end




function Element:isHovered()
    return self._hovered
end


function Element:isActive()
    --[[
        returns whether an element is active or not.

        If an element was :render()ed the previous frame,
        then its active.
    ]]
    return self._active
end



function Element:isClickedOnBy(button)
    -- returns true iff the element is clicked on by
    return self._clickedOnBy[button]
end



function Element:contains(x,y)
    -- returns true if (x,y) is inside element bounds
    local X,Y,W,H = self:getView()
    return  X < x and x < (X+W)
        and Y < y and y < (Y+H)
end



return Element
