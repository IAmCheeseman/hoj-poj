

local util = {}


function util.tryCall(func, ...)
    -- calls `func` if it isnt nil
    if func then
        return func(...)
    end
end


function util.find(arr, elem)
    for i=1, #arr do
        if arr[i] == elem then
            return i
        end
    end
end


function util.listDelete(arr, elem)
    -- todo: this is bad, O(n^2)
    local i = util.find(arr, elem)
    if i then
        table.remove(arr, i)
    end
end


function util.Class()
    local Class = {}
    local mt = {__index = Class}

    local function new(_class, ...)
        local obj = {}
        setmetatable(obj, mt)
        if Class.init then
            Class.init(obj, ...)
        end
        return obj
    end

    return setmetatable(Class, {
        __call = new
    })
end


return util

