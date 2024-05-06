(fn find-level [world name]
  (?.
   (icollect [_ { : identifier &as level} (ipairs (. world :levels))]
     (if (or (= name identifier)
             (= (.. "Level_" name) identifier)
             (= (.. "level_" name) identifier))
         level))
   1))

(fn parse-tile-details [{: enumTags}]
  (local enum-map {})
  (each [k {:enumValueId enum : tileIds} (ipairs enumTags)]
    (each [x tileId (ipairs tileIds)]
      (if (?. enum-map tileId)
          (table.insert (?. enum-map tileId) enum)
          (tset enum-map tileId [enum])))
    )
  enum-map)

(fn find-details [{: defs}]
  {:tilesets (icollect [_ v (ipairs (. defs :tilesets))]
               (do (tset v :enums (parse-tile-details v))
                   v))
   })

(fn get-tile-enums [tile tileset-uid tilesets]
  (?. (icollect [_ {: uid : enums} (ipairs tilesets)]
        (if (= tileset-uid uid) (?. enums tile)))
      1))

(fn parse-layer [{:__tilesetRelPath imagetable
                  :__tilesetDefUid tileset-uid
                  :__type layer-type
                  :__identifier layer-id
                  :gridTiles tiles
                  :entityInstances entities
                  :__gridSize grid-size}
                 {:w map-width :h map-height : tilesets}]
  (let [(_ _ tile-w tile-h)   (if imagetable
                                  (string.find imagetable ".+%-table%-(%d+)%-(%d+)%..+")
                                  (values nil nil grid-size grid-size))
        tile-w (tonumber (or tile-w grid-size))
        tile-h (tonumber (or tile-h grid-size))
        tiles (icollect [_ {:px [x y] : t} (ipairs tiles)]
                {:x (+ (// x tile-w) 1) :y (+ (// y tile-h) 1) :tile (+ t 1) :tile-enums (get-tile-enums t tileset-uid tilesets)})
        entities (icollect [_ {:px [x y] :__identifier id
                               : width : height
                               : fieldInstances} (ipairs entities)]
                   {:x x :y y : id
                    : width : height
                    :fields
                    (collect [_ {:__identifier key :__value val} (ipairs fieldInstances)] (values key val))})
        ]
    {: imagetable : tiles : tile-w : tile-h
     : layer-type : entities : layer-id
     :map-w map-width :map-h map-height
     :grid-w (// map-width tile-w) :grid-h (// map-height tile-h)
     }))

(fn parse-level [{: layerInstances :pxWid w :pxHei h &as level}
                 {: tilesets &as world}]
  (let [layers (icollect [_ layer (ipairs layerInstances)]
                 (parse-layer layer {: w : h : tilesets}))]
    {: layers : w : h}))

{: parse-level : find-level : find-details}
