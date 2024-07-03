local lui = require("editor.lui")
local kg = require("editor.kirigami")
local ui = require("editor.ui")
local data = require("editor.data")
local ObjButton = require("editor.obj_button")

local ObjPanel = lui.Element()

function ObjPanel:init()
  self.type = "ObjPanel"

  self.objs = {}

  local objids = data.getObjIds()
  for _, id in ipairs(objids) do
    local obj = data.getObj(id)
    local objbtn = ObjButton(obj, id)
    table.insert(self.objs, objbtn)
    self:addChild(objbtn)
  end

  self.maxnamelen = 10
  self.maxtabs = 5
end

function ObjPanel:onRender(x, y, w, h)
  local r = kg.Region(x, y, w, h)
  local barr, contentr = r:splitVertical(0.1, 0.9)
  local titler, tabsr = barr:splitHorizontal(0.1, 0.9)

  ui.rectangle(ui.bgcol, "fill", r:get())
  ui.rectangle(ui.olcol, "line", r:get())

  ui.rectangle(ui.olcol, "line", titler:get())
  ui.text(ui.fgcol, ui.font, "Objects", "center", titler:get())

  -- Tabs
  local objcats = data.getObjCategories()
  local rows = tabsr:rows(self.maxtabs)
  for i=1, self.maxtabs do
    local tabr = rows[i]

    if not objcats[i] then
      break
    end

    tabr = tabr:padPixels(ui.padding, 0)
    ui.rectangle(ui.olcol, "line", tabr:get())

    local displayname = objcats[i]
    if #displayname > self.maxnamelen then
      displayname = displayname:sub(1, self.maxnamelen - 3) .. "..."
    end
    ui.text(ui.fgcol, ui.font, displayname, "center", tabr:get())
  end

  ui.rectangle(ui.olcol, "line", contentr:get())
  local gw, gh = math.floor(contentr.w / 96), math.floor(contentr.h / 64)
  local slots = contentr:grid(gw, gh)
  for i, objbtn in ipairs(self.objs) do
    local slotr = slots[i]
    objbtn:render(slotr:padPixels(ui.padding):get())
  end

  -- ui.text(
  --   ui.unimpfgcol, ui.titlefont,
  --   "Object selection goes here", "center", contentr:get())
end

return ObjPanel
