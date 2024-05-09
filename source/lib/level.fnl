(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(defns :source.lib.level
  [gfx playdate.graphics]

  (fn prepare-entity-layer [{: entities : grid-w : grid-h : tile-h : tile-w}]
    {: entities : tile-h : tile-w})

  (fn prepare-tile-layer [{: layer-id : imagetable : tiles : grid-w : grid-h : tile-h : tile-w
                           : tile-enums : layer-enums}]
    (let [tileset (gfx.imagetable.new imagetable)
          tilemap (gfx.tilemap.new)
          _       (tilemap:setImageTable tileset)]
      (tilemap:setSize grid-w grid-h)
      (each [_ {: x : y : tile} (ipairs tiles)]
        (tilemap:setTileAtPosition x y tile))
      {: tilemap : layer-id : tile-h : tile-w : layer-enums : tile-enums}))

  (fn prepare-level [{: layers : w : h}]
    (let [tile-layers (icollect [_ { : layer-type &as l} (ipairs layers)]
                   (if (= :Tiles layer-type)
                       (prepare-tile-layer l)))
          entity-layers (icollect [_ { : layer-type &as l} (ipairs layers)]
                        (if (= :Entities layer-type)
                            (prepare-entity-layer l)
                            ))]
      {: tile-layers : entity-layers : w : h}))

  (fn tile-layer-sprite [layer solid?]
    (let [bg (gfx.sprite.new)
          walls (if solid?
                    (gfx.sprite.addWallSprites layer.tilemap)
                    [])]
      ;; Assumes all walls are slide + group 4
      (each [_ sprite (ipairs walls)]
        (tset sprite :wall? true)
        (tset sprite :collisionResponse #gfx.sprite.kCollisionTypeSlide)
        (sprite:setGroups [4])
        ;; (sprite:setCollidesWithGroups [1])
        )
      (bg:setTilemap layer.tilemap)
      (bg:setCenter 0 0)
      (bg:moveTo 0 0)
      (bg:setZIndex (if solid? -90 -100))
      (bg:add)
      {:tilemap layer.tilemap
       :sprite  bg})
    )


  (fn add-entities! [{: tile-h : tile-w &as layer} entity-map]
    (icollect [_ {: id : width : height : x : y : fields} (ipairs layer.entities)]
      (let [entity-mod (?. entity-map id)
            entity (if entity-mod
                       (entity-mod.new! x y {: fields : tile-h : tile-w : width : height}))]
        (if entity (entity:add))
        entity)))

  ;; TODO: Make a level parser that can take entities map and prep a full level
  ;; (normalize the code from calm-sea and standardize)
  (fn prepare-level! [level-data entity-map]
    (let [loaded (prepare-level level-data)
          layers (icollect [_ {: layer-enums &as layer} (ipairs loaded.tile-layers)]
                   (if
                    (?. (icollect [_ v (ipairs (. layer :layer-enums))] (if (= "wall" v) true)) 1)
                    (tile-layer-sprite layer true)
                    (tile-layer-sprite layer)))
          entities (?. loaded :entity-layers 1)
          entities (add-entities! entities entity-map)]
      {
       :stage-width loaded.w :stage-height loaded.h
       :ticks 0
       : layers
       : entities
       }))

  )
