(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(defns :source.lib.level
  [gfx playdate.graphics]

  (fn prepare-entity-layer [{: entities : grid-w : grid-h}]
    {: entities})

  (fn prepare-tile-layer [{: imagetable : tiles : grid-w : grid-h}]
    (let [tileset (gfx.imagetable.new imagetable)
          tilemap (gfx.tilemap.new)
          _       (tilemap:setImageTable tileset)]
      (tilemap:setSize grid-w grid-h)
      (each [_ {: x : y : tile} (ipairs tiles)]
        (tilemap:setTileAtPosition x y tile))
      {: tilemap}))

  (fn prepare-level [{: layers : w : h}]
    (let [tile-layers (icollect [_ { : layer-type &as l} (ipairs layers)]
                   (if (= :Tiles layer-type)
                       (prepare-tile-layer l)))
          entity-layers (icollect [_ { : layer-type &as l} (ipairs layers)]
                        (if (= :Entities layer-type)
                            (prepare-entity-layer l)
                            ))]
      {: tile-layers : entity-layers : w : h}))
  )
