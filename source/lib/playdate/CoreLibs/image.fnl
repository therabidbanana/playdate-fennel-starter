(import-macros {: defns} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :image))
    (tset _G.playdate.graphics :image {}))

(tset
 _G.playdate :graphics :image
 (defns :image []
   (fn new [path] "TODO")))
