(fn find-level [world name]
  (?.
   (icollect [_ { : identifier &as level} (ipairs (. world :levels))]
     (if (or (= name identifier) (= (.. "Level_" name) identifier))
         level))
   1))

(fn parse-layer [{:__tilesetRelPath imagetable :gridTiles tiles :__gridSize grid-size}
                 {:w map-width :h map-height}]
  (let [(_ _ tile-w tile-h)   (string.find imagetable ".+%-table%-(%d+)%-(%d+)%..+")
        tile-w (tonumber tile-w)
        tile-h (tonumber tile-h)
        tiles (icollect [_ {:px [x y] : t} (ipairs tiles)]
                {:x (+ (// x tile-w) 1) :y (+ (// y tile-h) 1) :tile (+ t 1)})]
    {: imagetable : tiles : tile-w : tile-h :w (// map-width tile-w) :h (// map-height tile-h)}))

(fn parse-level [{: layerInstances :pxWid w :pxHei h}]
  (let [layers (icollect [_ layer (ipairs layerInstances)]
                 (parse-layer layer {: w : h}))]
    {: layers : w : h}))

{: parse-level : find-level}
