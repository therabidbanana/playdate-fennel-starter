(fn find-level [world name]
  (?.
   (icollect [_ { : identifier &as level} (ipairs (. world :levels))]
     (if (or (= name identifier) (= (.. "Level_" name) identifier))
         level))
   1))

(fn parse-layer [{:__tilesetRelPath imagetable
                  :__type layer-type
                  :gridTiles tiles
                  :entityInstances entities
                  :__gridSize grid-size}
                 {:w map-width :h map-height}]
  (let [(_ _ tile-w tile-h)   (if imagetable
                                  (string.find imagetable ".+%-table%-(%d+)%-(%d+)%..+")
                                  (values nil nil grid-size grid-size))
        tile-w (tonumber (or tile-w grid-size))
        tile-h (tonumber (or tile-h grid-size))
        tiles (icollect [_ {:px [x y] : t} (ipairs tiles)]
                {:x (+ (// x tile-w) 1) :y (+ (// y tile-h) 1) :tile (+ t 1)})
        entities (icollect [_ {:px [x y] :__identifier id} (ipairs entities)]
                   {:x x :y y : id })
        ]
    {: imagetable : tiles : tile-w : tile-h
     : layer-type : entities
     :map-w map-width :map-h map-height
     :grid-w (// map-width tile-w) :grid-h (// map-height tile-h)
     }))

(fn parse-level [{: layerInstances :pxWid w :pxHei h}]
  (let [layers (icollect [_ layer (ipairs layerInstances)]
                 (parse-layer layer {: w : h}))]
    {: layers : w : h}))

{: parse-level : find-level}
