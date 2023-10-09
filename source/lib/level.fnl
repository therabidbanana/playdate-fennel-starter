(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(defns :source.lib.level
  [gfx playdate.graphics]

  (fn prepare-layer [{: imagetable : tiles : w : h}]
    (let [tileset (gfx.imagetable.new imagetable)
          tilemap (gfx.tilemap.new)
          _       (tilemap:setImageTable tileset)]
      (tilemap:setSize w h)
      (each [_ {: x : y : tile} (ipairs tiles)]
        (tilemap:setTileAtPosition x y tile))
      {: tilemap}))

  (fn prepare-level [{: layers : w : h}]
    (let [layers (icollect [_ l (ipairs layers)] (prepare-layer l))]
      {: layers : w : h}))
  )
