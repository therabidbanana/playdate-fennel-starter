(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :image))
    (tset _G.playdate.graphics :image {}))

(defmodule
 _G.playdate.graphics.image
 []
 (fn new [path] {}))
