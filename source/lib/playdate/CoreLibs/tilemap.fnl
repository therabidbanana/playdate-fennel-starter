(import-macros {: inspect : defmodule} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate :graphics :tilemap))
    (tset _G.playdate :graphics :tilemap {}))

(defmodule _G.playdate.graphics.tilemap
  []

  (fn setImageTable [self imagetable]
    (tset self :imagetable imagetable)
    (tset self :spritebatch (love.graphics.newSpriteBatch imagetable.atlas))
    )

  (fn draw [self x y]
    (love.graphics.draw self.spritebatch x y)
    )

  (fn setSize [] "TODO")
  (fn setTileAtPosition [self x y quad]
    (let [tile-x (* (- x 1) self.imagetable.tile-w)
          tile-y (* (- y 1) self.imagetable.tile-h)]
      (self.spritebatch:add (?. self.imagetable.quads quad) tile-x tile-y))
    )
  (fn setTilemap [] "TODO")
  (fn new [] { : draw : setImageTable : setSize : setTileAtPosition : setTilemap })
  )
