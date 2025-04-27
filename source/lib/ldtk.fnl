(import-macros {: div} :source.lib.macros)

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
  {:tilesets (collect [_ v (ipairs (. defs :tilesets))]
               (do (tset v :enums (parse-tile-details v))
                   (values (. v :uid) v)))
   :layers (collect [_ v (ipairs (. defs :layers))]
             (values (. v :uid) v))

   })

(fn mutated-tile-enums [tileset-uid tilesets]
  (case (?. tilesets tileset-uid :enums)
    found-enums (collect [k v (pairs found-enums)]
                  (values (+ 1 k) v))))

(fn parse-layer [{:__tilesetRelPath imagetable
                  :__tilesetDefUid tileset-uid
                  :__type layer-type
                  :layerDefUid layer-id
                  :gridTiles tiles
                  :entityInstances entities
                  :__gridSize grid-size}
                 {:w map-width :h map-height : tilesets : layers}]
  (let [(_ _ tile-w tile-h)   (if imagetable
                                  (string.find imagetable ".+%-table%-(%d+)%-(%d+)%..+")
                                  (values nil nil grid-size grid-size))
        layer-def (?. layers layer-id)
        layer-name (?. layer-def :identifier)
        tile-w (tonumber (or tile-w grid-size))
        tile-h (tonumber (or tile-h grid-size))
        tiles (icollect [_ {:px [x y] : t} (ipairs tiles)]
                {:x (+ (div x tile-w) 1) :y (+ (div y tile-h) 1) :tile (+ t 1)})
        entities (icollect [_ {:px [x y] :__identifier id
                               : width : height
                               : fieldInstances} (ipairs entities)]
                   {: x : y : id : width : height
                    :fields
                    (collect [_ {:__identifier key :__value val} (ipairs fieldInstances)] (values key val))})
        tile-enums (mutated-tile-enums tileset-uid tilesets)
        layer-enums (?. layer-def :uiFilterTags)
        ]
    {: imagetable : tiles : tile-w : tile-h
     : layer-type : entities
     : tile-enums : layer-enums
     : layer-name : layer-id
     :map-w map-width :map-h map-height
     :grid-w (div map-width tile-w) :grid-h (div map-height tile-h)
     }))

(fn parse-level [{: layerInstances :pxWid w :pxHei h &as level
                  : fieldInstances }
                 {: tilesets : layers &as world}]
  (let [layers (icollect [_ layer (ipairs layerInstances)]
                 (parse-layer layer {: w : h : tilesets : layers}))
        fields (collect [_ {:__identifier key :__value val} (ipairs fieldInstances)] (values key val))]
    {: layers : w : h : fields}))

{: parse-level : find-level : find-details}
