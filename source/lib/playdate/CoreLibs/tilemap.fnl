(import-macros {: inspect : defmodule : div} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate :graphics :tilemap))
    (tset _G.playdate :graphics :tilemap {}))

(defmodule _G.playdate.graphics.tilemap
  [
   love-wrap (require :source.lib.playdate.love-wrap)
   ]

  (fn setImageTable [self imagetable]
    (tset self :imagetable imagetable)
    (tset self :spritebatch (love.graphics.newSpriteBatch imagetable.atlas))
    )

  (fn draw [self x y]
    (love-wrap.draw self.spritebatch x y)
    )

  (fn setSize [self tiles-w tiles-h]
    (tset self :tiles-w tiles-w)
    (tset self :tiles-h tiles-h)
    ;; TODO: should this wipe values?
    (let [old-tiles self.tiles]
      (tset self :tiles [])
      (for [x 1 tiles-w]
        (for [y 1 tiles-h]
          (tset self :tiles (+ x (* tiles-w (- y 1))) 0)))
      )
    )

  (fn getTiles [self]
    (values self.tiles self.tiles-w))

  (fn getTileSize [self]
    (values self.imagetable.tile-w self.imagetable.tile-h))

  (fn getSize [self]
    (values self.tiles-w self.tiles-h))

  (fn getPixelSize [self]
    (values (* self.tiles-w self.imagetable.tile-w) (* self.tiles-h self.imagetable.tile-h)))

  (fn setTileAtPosition [self x y tileId]
    (let [tile-x (* (- x 1) self.imagetable.tile-w)
          tile-y (* (- y 1) self.imagetable.tile-h)
          tile-quad (?. self.imagetable.quads tileId)]
      (if tile-quad (self.spritebatch:add tile-quad tile-x tile-y))
      (tset self :tiles (+ (* self.tiles-w (- y 1)) x) tileId)))

  (fn setTilemap [] "TODO")
  (fn getCollisionRects [self emptyIDs]
    (let [tile-w self.imagetable.tile-w
          tile-h self.imagetable.tile-h
          ignored? (collect [i a (ipairs (or emptyIDs [])) &into {0 true}]
                     (values a true))]
      (icollect [i tileId (ipairs self.tiles)]
        (let [tile-x (% (- i 1) self.tiles-w)
              tile-y (div (- i 1) self.tiles-w)]
          (if (?. ignored? tileId)
              nil
              (_G.playdate.geometry.rect.new (* tile-x tile-w) (* tile-y tile-h)
                                             tile-h tile-w))))))

  (fn new []
    (let [tiles []
          tiles-w 1
          tiles-h 1]
      { : tiles : tiles-w : tiles-h
        : getCollisionRects : getTileSize : getTiles
        : getPixelSize : getSize
        : draw : setImageTable : setSize : setTileAtPosition : setTilemap }))
  )
