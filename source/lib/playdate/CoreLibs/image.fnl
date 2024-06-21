(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :image))
    (tset _G.playdate.graphics :image {}))

(defmodule
 _G.playdate.graphics.image
 []
 (fn draw [self x y]
   (love.graphics.draw self.image x y)
   )

 (fn new [path-or-data]
   (let [path-or-data (if (= (type path-or-data) :string)
                          (.. path-or-data :.png)
                          path-or-data)
         image (love.graphics.newImage path-or-data)]
     {: image : draw})
   ))
