local sound = {}

local sounds = {}

love.audio.setVolume(0.5)

function sound.load(name, path, max_sources)
  max_sources = max_sources or 5

  local sound_data = love.sound.newSoundData(path)

  local sources = {}
  for _=1, max_sources do
    table.insert(sources, love.audio.newSource(sound_data))
  end

  sounds[name] = {
    current = 1,
    sources = sources,
  }
end

function sound.play(name, randomize_pitch)
  local s = sounds[name] or error("Sound '" .. name .. "' does not exist.")
  local source = s.sources[s.current]
  s.current = s.current + 1
  if s.current > #s.sources then
    s.current = 1
  end

  if randomize_pitch then
    source:setPitch(mathx.frandom(0.9, 1.1))
  end

  source:stop()
  source:play()
end

return sound
