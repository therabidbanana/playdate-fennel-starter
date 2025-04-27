(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :image))
    (tset _G.playdate.graphics :image {}))

(defmodule
 _G.playdate.graphics.image
 [
  love-wrap (require :source.lib.playdate.CoreLibs.love-wrap)
  ]

 (fn getSize [self]
   (self.image:getDimensions))

 (fn draw [self x y]
   (love-wrap.draw self.image x y)
   )

 (fn drawFaded [self x y alpha]
   (let [shader (love.graphics.getShader)]
     (love.graphics.push :all)
     ;; TODO: shader should support faded
     (love.graphics.setShader)
     (love.graphics.setColor (/ 176 255) (/ 174 255) (/ 167 255) alpha)
     (love-wrap.draw self.image x y)
     (love.graphics.setShader shader)
     (love.graphics.pop))
   )

 (fn new [path-or-data height]
   (let [path-or-data (if (= (type path-or-data) :string)
                          (.. path-or-data :.png)
                          path-or-data)
         image (if height
                   (love.graphics.newCanvas path-or-data height)
                   (love.graphics.newImage path-or-data))]
     {: image : draw : drawFaded : getSize})
   ))
