local confpath = "editor.conf"
local conf

local layers = {}
local tilesets = {}
local objs = {}
local maps = {}
local objcats = {}

local ids = {}

local data = {}

function data.reloadData()
  -- Reload config
  package.loaded[confpath] = nil
  conf = require(confpath)

  layers = {}
  tilesets = {}
  objs = {}
  maps = {}
  objcats = {}

  ids.layers = {}
  ids.tilesets = {}
  ids.objs = {}
  ids.maps = {}

  for i, layer in ipairs(conf.layers) do
    table.insert(ids.layers, i)
    layer.id = i
    layers[layer.name] = layer
    layers[i] = layer
  end

  local objid = 1
  for _, cat in ipairs(conf.objcateories) do
    objs[cat.name] = {}
    table.insert(objcats, cat.name)
    for i, obj in ipairs(cat.objs) do
      table.insert(ids.objs, {category=cat.name, index=i})
      obj.id = objid
      objs[cat.name][obj.name] = obj
      objs[cat.name][i] = obj

      objid = objid + 1
    end
  end

  for i, tileset in ipairs(conf.tilesets) do
    table.insert(ids.tilesets, i)
    tileset.id = i
    tilesets[tileset.name] = tileset
    tilesets[i] = tileset
  end

  for i, map in ipairs(conf.maps) do
    table.insert(ids.maps, i)
    map.id = i
    maps[map.name] = map
    maps[i] = map
  end
end

function data.getLayerIds()
  return ids.layers
end

function data.getObjIds()
  return ids.objs
end

function data.getObjCategories()
  return objcats
end

function data.getTilesetIds()
  return ids.tilesets
end

function data.getMapIds()
  return ids.maps
end

function data.getLayer(id)
  return layers[id] or error("No layer with the id '" .. id .. "'", 1)
end

function data.getObj(id)
  return objs[id.category][id.index] or error("No object with the id '" .. id .. "'", 1)
end

function data.getTileset(id)
  return tilesets[id] or error("No tileset with the id '" .. id .. "'", 1)
end

function data.getMap(id)
  return maps[id] or error("No map with the id '" .. id .. "'", 1)
end

-- Initial load
data.reloadData()

return data
