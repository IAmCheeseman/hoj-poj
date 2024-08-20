function makeWeapon(t)
  t.spawnBullets = t.spawnBullets or error("Need spawn function")
  t.reloadTime = t.reloadTime or error("Need reload time")
  t.semiAutomatic = t.semiAutomatic or false
end

return makeWeapon
