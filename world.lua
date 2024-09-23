local world = {}

local next_id = 1

local obj_meta = {}
-- local objs = {}
local tags = {}

-- Addition and removal queues for tags.
local tag_addq = {}
local tag_remq = {}

-- Add queue
local addq = {}
-- Add set, so we know what we're adding at the end of the frame
local add_set = {}
-- Same, but for removal
local remq = {}
local rem_set = {}

local proc_list = {}
local proc_list_addq = {}
local proc_list_remq = {}

-- Drawing has a specific order it must be done in; it has to be a list.
local draw_list = {}
local draw_list_addq = {}
local draw_list_remq = {}
-- Same with gui
local gui_list = {}
local gui_list_addq = {}
local gui_list_remq = {}

local deferred_draw = {}

world.is_paused = false

function world.deferDraw(fn)
  table.insert(deferred_draw, fn)
end

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
    if meta then
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
  end

  tag_remq = {}
end

function world.defaultDraw(self)
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(self.x, self.y, self.rot or 0)
end

local function flushAdd()
  for _, obj in ipairs(addq) do
    -- table.insert(objs, obj)

    obj.x = obj.x or 0
    obj.y = obj.y or 0
    obj.z_index = obj.z_index or 0

    -- If an object has a sprite but no draw, automatically draw sprite
    if obj.sprite and not obj.draw and not obj.no_draw then
      obj.draw = world.defaultDraw
    end

    local meta = {
      -- index = #objs,
      id = next_id,
      tags = {},
    }
    obj_meta[obj] = meta

    next_id = next_id + 1

    if obj.step then
      table.insert(proc_list, obj)
      meta.proc_list_index = #proc_list
    end

    if obj.draw then
      table.insert(draw_list, obj)
      meta.draw_list_index = #draw_list
    end

    if obj.gui then
      table.insert(gui_list, obj)
      meta.gui_list_index = #gui_list
    end

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

local function removeFromList(dl, m, idx_k)
  local _, new = tablex.swapRem(dl, m[idx_k])

  -- Keep indices correct
  if new then
    obj_meta[new][idx_k] = m[idx_k]
  end

  m[idx_k] = nil
end

local function flushRem()
  for _, obj in ipairs(remq) do
    local _ = try(obj.removed, obj)

    local meta = obj_meta[obj]

    if meta.proc_list_index then
      removeFromList(proc_list, meta, "proc_list_index")
    end

    if meta.draw_list_index then
      removeFromList(draw_list, meta, "draw_list_index")
    end

    if meta.gui_list_index then
      removeFromList(gui_list, meta, "gui_list_index")
    end

    obj_meta[obj] = nil
  end

  remq = {}
  rem_set = {}
end

local function flushListAdd(q, dl, idx_k)
  for _, obj in ipairs(q) do
    local meta = obj_meta[obj]
    table.insert(dl, obj)
    meta[idx_k] = #dl
  end
end

local function flushListRem(q, dl, idx_k)
  for _, obj in ipairs(q) do
    local meta = obj_meta[obj]
    if meta[idx_k] then
      removeFromList(dl, meta, idx_k)
    end
  end
end

function world.flush()
  flushAdd()
  flushTagRem()

  flushRem()
  flushTagAdd()

  flushListAdd(proc_list_addq, proc_list, "proc_list_index")
  proc_list_addq = {}
  flushListRem(proc_list_remq, proc_list, "proc_list_index")
  proc_list_remq = {}

  flushListAdd(draw_list_addq, draw_list, "draw_list_index")
  draw_list_addq = {}
  flushListRem(draw_list_remq, draw_list, "draw_list_index")
  draw_list_remq = {}

  flushListAdd(gui_list_addq, gui_list, "gui_list_index")
  gui_list_addq = {}
  flushListRem(gui_list_remq, gui_list, "gui_list_index")
  gui_list_remq = {}
end

local function canStep(obj)
  return not world.is_paused or obj.step_while_paused
end

function world.clear(t)
  addq = {}
  remq = {}
  rem_set = {}
  proc_list_addq = {}
  proc_list_remq = {}
  draw_list_addq = {}
  draw_list_remq = {}
  gui_list_addq = {}
  gui_list_remq = {}

  t = t or {}
  for obj, _ in pairs(obj_meta) do
    if not obj.persistent then
      world.rem(obj)
    else
      try(obj.worldCleared, obj, t)
    end
  end
end

function world.update(dt)
  for _, obj in ipairs(proc_list) do
    if is(obj.step, "function") then
      if canStep(obj) then
        obj:step(dt)
      end
    else
      world.remProc(obj)
    end
  end
end

function world.draw()
  table.sort(draw_list, function(a, b)
    local az = a.z_index
    local bz = b.z_index
    if az == bz then
      az = obj_meta[a].id
      bz = obj_meta[b].id
    end
    return az < bz
  end)

  table.sort(gui_list, function(a, b)
    local az = a.z_index
    local bz = b.z_index
    if az == bz then
      az = obj_meta[a].id
      bz = obj_meta[b].id
    end
    return az < bz
  end)

  viewport.apply()
  for i, obj in ipairs(draw_list) do
    obj_meta[obj].draw_list_index = i
    obj:draw()
  end

  for _, fn in ipairs(deferred_draw) do
    fn()
  end
  deferred_draw = {}

  viewport.stop()

  viewport.applyGui()
  for i, obj in ipairs(gui_list) do
    obj_meta[obj].gui_list_index = i
    obj:gui()
  end
  viewport.stopGui()
end

function world.addProc(obj)
  if not is(obj.step, "function") then
    error("Object must have a step function to be processed.")
  end

  table.insert(proc_list_addq, obj)
end

function world.remProc(obj)
  table.insert(proc_list_remq, obj)
end

function world.addDrawProc(obj)
  if not is(obj.draw, "function") then
    error("Object must have a draw function to be drawn.")
  end

  table.insert(draw_list_addq, obj)
end

function world.remDrawProc(obj)
  table.insert(draw_list_remq, obj)
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

function world.isTagged(obj, tag)
  local meta = obj_meta[obj] or error("Object is not added to the world")
  return meta.tags[tag] ~= nil
end

return world
