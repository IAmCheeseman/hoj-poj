function softCollision(self)
  local r = self.soft_coll_radius or 8

  local pushx, pushy = 0, 0

  local tagged = world.getTagged("soft_coll")
  if #tagged == 0 then
    return 0, 0
  end

  for _, obj in ipairs(tagged) do
    local r2 = obj.soft_coll_radius or 4
    local dist = vec.distanceSq(obj.x, obj.y, self.x, self.y)
    if dist < (r + r2)^2 then
      local dirx, diry = vec.direction(obj.x, obj.y, self.x, self.y)
      pushx = pushx + dirx
      pushy = pushy + diry
    end
  end

  return vec.normalized(pushx, pushy)
end
