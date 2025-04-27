(import-macros {: defmodule : div : inspect} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :nineSlice))
    (tset _G.playdate.graphics :nineSlice {}))

(defmodule
 _G.playdate.graphics.nineSlice
 [
  love-wrap (require :source.lib.playdate.CoreLibs.love-wrap)
  ]

 (fn drawInRect [self x y w h]
   (if (and (= self.cache-w w) (= self.cache-h h) false)
       (love-wrap.draw self.cache-img x y)
       (let [batch (love.graphics.newSpriteBatch self.img)
             mx self.inner-dims.x
             my self.inner-dims.y
             mw (- w (- self.outer-dims.w self.inner-dims.w))
             mh (- h (- self.outer-dims.h self.inner-dims.h))
             scale-l (/ mh self.inner-dims.h)
             scale-r (/ mh self.inner-dims.h)
             scale-t (/ mw self.inner-dims.w)
             scale-b (/ mw self.inner-dims.w)
             scale-mx (/ w mw)
             scale-my (/ h mh)
             ]
         (for [sy 0 (math.floor scale-l)]
           (for [sx 0 (math.floor scale-t)]
             (batch:add self.quads.mm
                        (+ mx (* sx self.inner-dims.w))
                        (+ my (* sy self.inner-dims.h)) 0 1 1)))
         (for [s 0 (math.floor scale-t)]
           (batch:add self.quads.tm (+ mx (* s self.inner-dims.w)) 0 0 1 1)
           )
         (for [s 0 (math.floor scale-b)]
           (batch:add self.quads.bm (+ mx (* s self.inner-dims.w)) (+ my mh) 0 1 1)
           )
         (for [s 0 (math.floor scale-l)]
           (batch:add self.quads.ml 0 (+ my (* s self.inner-dims.h)) 0 1 1)
           )
         (for [s 0 (math.floor scale-r)]
           (batch:add self.quads.mr (+ mw mx) (+ my (* s self.inner-dims.h)) 0 1 1)
           )
         ;; (batch:add self.quads.ml 0 0 0 1 scale-l)
         ;; (batch:add self.quads.mr (+ mx mw) 0 0 1 scale-r)
         (batch:add self.quads.tl 0 0 0 1 1)
         (batch:add self.quads.tr (+ mw mx) 0 0 1 1)
         (batch:add self.quads.bl 0 (+ my mh) 0 1 1)
         (batch:add self.quads.br (+ mw mx) (+ my mh) 0 1 1)
         (tset self :cache-img batch)
         (tset self :cache-w w)
         (tset self :cache-h h)
         (love-wrap.draw batch x y)
         ))
   )

 (fn new [path inner-x inner-y inner-w inner-h]
   (let [full-file (.. path :.png)
         img (love.graphics.newImage full-file)
         (width height) (img:getDimensions)
         left-w inner-x
         right-w (- width inner-w left-w)
         top-h inner-y
         bottom-h (- height inner-h top-h)
         right-x (+ inner-x inner-w)
         bottom-y (+ inner-y inner-h)
         inner-dims {:h inner-h :w inner-w :x inner-x :y inner-y}
         outer-dims {:h height :w width :l left-w :r right-w :t top-h :b bottom-h}
         quads {}]
     (tset quads :tl (love.graphics.newQuad 0        0         left-w   top-h    width height))
     (tset quads :tm (love.graphics.newQuad inner-x  0         inner-w  top-h    width height))
     (tset quads :tr (love.graphics.newQuad right-x  0         right-w  top-h    width height))
     (tset quads :ml (love.graphics.newQuad 0        inner-y   left-w   inner-h  width height))
     (tset quads :mm (love.graphics.newQuad inner-x  inner-y   inner-w  inner-h  width height))
     (tset quads :mr (love.graphics.newQuad right-x  inner-y   right-w  inner-h  width height))
     (tset quads :bl (love.graphics.newQuad 0        bottom-y  left-w   bottom-h width height))
     (tset quads :bm (love.graphics.newQuad inner-x  bottom-y  inner-w  bottom-h width height))
     (tset quads :br (love.graphics.newQuad right-x  bottom-y  right-w  bottom-h width height))
     {: drawInRect : quads : img : inner-dims : outer-dims})
   )
 )
