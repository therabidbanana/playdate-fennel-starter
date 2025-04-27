(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(defns :source.lib.level
  [gfx playdate.graphics]

  (fn prepare-entity-layer [{: entities : grid-w : grid-h : tile-h : tile-w}]
    {: entities : tile-h : tile-w})

  (fn prepare-tile-layer [{: layer-id : imagetable : tiles : grid-w : grid-h : tile-h : tile-w
                           : layer-name : tile-enums : layer-enums}]
    (let [tileset (gfx.imagetable.new imagetable)
          tilemap (gfx.tilemap.new)
          _       (tilemap:setImageTable tileset)]
      (tilemap:setSize grid-w grid-h)
      (each [_ {: x : y : tile} (ipairs tiles)]
        (tilemap:setTileAtPosition x y tile))
      {: tilemap : layer-id : layer-name : tile-h : tile-w : layer-enums : tile-enums}))

  (fn prepare-level [{: layers : w : h : fields}]
    (let [tile-layers (icollect [_ { : layer-type &as l} (ipairs layers)]
                   (if (= :Tiles layer-type)
                       (prepare-tile-layer l)))
          entity-layers (icollect [_ { : layer-type &as l} (ipairs layers)]
                        (if (= :Entities layer-type)
                            (prepare-entity-layer l)
                            ))]
      {: tile-layers : entity-layers : w : h : fields}))

  (fn tile-layer-sprite [layer solid? layer-details]
    (let [bg (gfx.sprite.new)
          solid? (or solid? (?. layer-details layer.layer-name :solid?))
          z-index (or (?. layer-details layer.layer-name :z-index)
                      (if solid? -90 -100))
          layer-details (or (?. layer-details layer.layer-name) {})
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
      (bg:setZIndex z-index)
      (bg:add)
      {:tilemap layer.tilemap
       :sprite  bg})
    )


  (fn add-entities! [{: tile-h : tile-w &as layer} entity-map layer-details all-entities]
    (icollect [_ {: id : width : height : x : y : fields} (ipairs layer.entities) &into all-entities]
      (let [entity-mod (?. entity-map id)
            ;; NOTE: Skips unknown entities instead of error
            entity (if entity-mod
                       (entity-mod.new! x y {: fields : tile-h : tile-w : width : height
                                             :layer-details (or (?. layer-details id) {})}))]
        (if (?. entity :add) (entity:add))
        entity)))

  (fn prepare-level! [level-data entity-map layer-details]
    (let [loaded (prepare-level level-data)
          layers (icollect [_ {: layer-enums &as layer} (ipairs loaded.tile-layers)]
                   (if
                    (?. (icollect [_ v (ipairs (. layer :layer-enums))] (if (= "wall" v) true)) 1)
                    (tile-layer-sprite layer true layer-details)
                    (tile-layer-sprite layer false layer-details)))
          all-entities []]
      (each [k v (ipairs (?. loaded :entity-layers))]
        (add-entities! v entity-map layer-details all-entities))
      {
       :stage-width loaded.w :stage-height loaded.h
       :fields loaded.fields
       :ticks 0
       : layers
       :entities all-entities
       }))

  )
