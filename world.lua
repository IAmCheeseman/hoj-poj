local world = {}

local next_id = 1

local obj_meta = {}
local objs = {}
local tags = {}

local tag_addq = {}
local tag_remq = {}

local addq = {}
local remq = {}
local add_set = {}
local rem_set = {}

function world.add(obj)
  if add_set[obj] then
    return false
  end

  add_set[obj] = true
  table.insert(addq, obj)
  return true
end

function world.rem(obj)
  if not obj_meta[obj] or rem_set[obj] then
    return false
  end

  rem_set[obj] = true
  table.insert(remq, obj)

  local meta = obj_meta[obj]
  for tag, _ in pairs(meta.tags) do
    world.untag(obj, tag)
  end

  return true
end

function world.tag(obj, tag)
  if not obj_meta[obj] then
    return false
  end

  table.insert(tag_addq, {name=tag, obj=obj})
  return true
end

function world.untag(obj, tag)
  if not obj_meta[obj] or not obj_meta[obj].tags[tag] then
    return false
  end

  if not tags[tag] then
    error("Tag '" .. tostring(tag) .. "' does not exist.")
  end

  table.insert(tag_remq, {name=tag, obj=obj})
  return true
end

local function flushTagAdd()
  for _, tag in ipairs(tag_addq) do
    local meta = obj_meta[tag.obj]
    local obj_tags = meta.tags

    if not tags[tag.name] then
      tags[tag.name] = {}
    end

    local tagt = tags[tag.name]
    table.insert(tagt, tag.obj)
    obj_tags[tag.name] = #tagt
  end

  tag_addq = {}
end

local function flushTagRem()
  for _, tag in ipairs(tag_remq) do
    local meta = obj_meta[tag.obj]
    local obj_tags = meta.tags

    local tagt = tags[tag.name]
    local _, new = tablex.swapRem(tagt, obj_tags[tag.name])

    -- Keep indices correct
    if new then
      local new_meta = obj_meta[new]
      new_meta.tags[tag.name] = obj_tags[tag.name]
    end

    -- Don't keep useless memory around
    if #tagt == 0 then
      tags[tag.name] = nil
    end

    obj_tags[tag.name] = nil
  end

  tag_remq = {}
end

local function defaultDraw(self)
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y, self.rot or 0)
end

local function flushAdd()
  for _, obj in ipairs(addq) do
    table.insert(objs, obj)

    obj.x = obj.x or 0
    obj.y = obj.y or 0
    obj.z_index = obj.z_index or 0

    -- If an object has a sprite but no draw, automatically draw sprite
    if obj.sprite and not obj.draw and not obj.no_draw then
      obj.draw = defaultDraw
    end

    local meta = {
      index = #objs,
      id = next_id,
      tags = {},
      children = {},
    }
    obj_meta[obj] = meta

    next_id = next_id + 1

    if is(obj.tags, "table") then
      for _, tag in ipairs(obj.tags) do
        world.tag(obj, tag)
      end

      obj.tags = nil
    end

    local _ = try(obj.added, obj)
  end

  addq = {}
  add_set = {}
end

local function updateParent(obj)
  local meta = obj_meta[obj]
  local parent = meta.parent
  local parent_meta = obj_meta[parent]

  local _, new = tablex.swapRem(parent_meta.children, meta.child_index)

  -- Keep indices correct
  if new then
    obj_meta[new].child_index = meta.child_index
  end
end

local function flushRem()
  for _, obj in ipairs(remq) do
    local _ = try(obj.removed, obj)

    local meta = obj_meta[obj]
    local _, new = tablex.swapRem(objs, meta.index)

    -- Keep indices correct
    if new then
      obj_meta[new].index = meta.index
    end

    -- Remove children
    for _, child in ipairs(meta.children) do
      local child_meta = obj_meta[child]

      -- We're getting rid of the parent; it no longer exists
      child_meta.parent = nil
      child_meta.child_index = nil

      world.rem(child)
    end

    if meta.parent then
      updateParent(obj)
    end

    obj_meta[obj] = nil
  end

  remq = {}
  rem_set = {}
end

function world.flush()
  flushTagAdd()
  flushTagRem()

  flushAdd()
  flushRem()
end

function world.update()
  for _, obj in ipairs(objs) do
    local _ = try(obj.step, obj)
  end
end

function world.draw()
  table.sort(objs, function(a, b)
    local az = a.z_index
    local bz = b.z_index
    if az == bz then
      az = obj_meta[a].id
      bz = obj_meta[b].id
    end
    return az < bz
  end)

  for i, obj in ipairs(objs) do
    obj_meta[obj].index = i

    if obj.draw then
      obj:draw()
    end
  end

  for _, obj in ipairs(objs) do
    if obj.gui then
      love.graphics.push()
      love.graphics.origin()
      obj:gui()
      love.graphics.pop()
    end
  end
end

function world.getSingleton(tag)
  local tagged = tags[tag]
  if tagged == nil then
    return nil
  end

  if #tagged ~= 1 then
    error("Tag '" .. tostring(tag) .. "' is not a singleton.")
  end

  return tagged[1]
end

function world.getTagged(tag)
  return tags[tag] or {}
end

function world.addChildTo(parent, child)
  local parent_meta = obj_meta[parent]
  local child_meta = obj_meta[parent]

  if not parent_meta then
    error("Parent is not added to the world.")
  end
  if not child_meta then
    error("Child is not added to the world.")
  end
  if child_meta.parent then
    error("Child already has a parent.")
  end

  table.insert(parent_meta.children, child)
  child_meta.parent = parent
  child_meta.child_index = #parent_meta.children
end

function world.getParent(child)
  local meta = obj_meta[child]
  if not meta then
    error("Object is not added to the world.")
  end

  return meta.parent
end

return world
