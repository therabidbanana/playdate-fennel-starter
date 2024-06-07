(import-macros {: inspect : defmodule } :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :sprite))
    (tset _G.playdate.graphics :sprite {}))

(defmodule
 _G.playdate.graphics.sprite
 []

 (local sprite-state {:sprites []})
 (fn update []
   (each [i sprite (ipairs sprite-state.sprites)]
     (sprite:update))
   (each [i sprite (ipairs sprite-state.sprites)]
     (sprite:draw sprite.x sprite.y sprite.width sprite.height))
   )

 (fn removeAll []
   (tset sprite-state :sprites [])
   )

 (fn performOnAllSprites [func]
   (each [i sprite (ipairs sprite-state.sprites)]
     (func sprite)))

 ;; Instance methods
 (fn setBounds [self x y w h]
   (tset self :x x)
   (tset self :y y)
   (tset self :width w)
   (tset self :height h))

 (fn setCenter [] "TODO")
 (fn setImage [self image] (tset self :image image))
 (fn instance-update [self])

 (fn draw [self]
   (self.image:draw self.x self.y)
   ;; (love.graphics.drawq self.image self.x self.y)
   )

 (fn add [self]
   (table.insert sprite-state.sprites self)
   (table.sort sprite-state.sprites
               (fn [a b] (< a.z-index b.z-index)))
   )

 (fn setTilemap [self tilemap]
   (tset self :image tilemap)
   )

 (fn markDirty [] "TODO")
 (fn moveTo [self x y]
   (tset self :x x)
   (tset self :y y))
 (fn moveBy [self dx dy]
   (tset self :x (+ self.x dx))
   (tset self :y (+ self.y dy)))
 (fn setZIndex [self z-index] (tset self :z-index z-index))
 (fn new []
   (let [x -800
         y -800
         z-index 0
         width 0
         height 0]
     { : x : y : width : height : z-index
       : add :update instance-update : draw : markDirty
       : setZIndex : setImage : setBounds : setCenter : setTilemap
       : moveTo : moveBy})
   )
 )
