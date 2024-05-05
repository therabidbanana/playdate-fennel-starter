(import-macros {: defns} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :animator))
    (tset _G.playdate.graphics :animator {}))

(tset
 _G.playdate :graphics :animator
 (defns :animator []

   (fn updateTimers [] "TODO")
   ;; Check on args here:
   (fn new [total-time start steps easing delayed] "TODO")))
