return {
  layers = {
    {
      name = "Collisions",
      type = "rect",
    },
    {
      name = "Objects",
      type = "object",
    },
    {
      name = "Buildings",
      type = "tile",
    },
  },
  objcateories = {
    {
      name = "Player",
      objs = {
        {
          name = "Player",
          image = "assets/player/player.ase",
        },
      },
    },
    {
      name = "Enemies",
      objs = {
        {
          name = "Mr. Scary",
          image = "assets/player/player.ase",
        }
      }
    }
  },
  tilesets = {
    {
      name = "Brick",
      image = "assets/env/brick.png",
      tilewidth = 8,
      tileheight = 8,
    },
  },
  mapautoname = "Level{index}",
  maps = {
    {
      name = "Overworld",
      save = "assets/map/start.map",
      infinite = true,
    },
  },
}
