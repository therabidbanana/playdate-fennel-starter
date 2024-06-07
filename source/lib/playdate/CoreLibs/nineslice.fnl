(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :nineSlice))
    (tset _G.playdate.graphics :nineSlice {}))

(defmodule
 _G.playdate.graphics.nineSlice
 [] (fn new [] "TODO"))
