(import-macros {: defns} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :nineSlice))
    (tset _G.playdate.graphics :nineSlice {}))

(tset
 _G.playdate :graphics :nineSlice
 (defns :nineSlice []
   (fn new [] "TODO")))
