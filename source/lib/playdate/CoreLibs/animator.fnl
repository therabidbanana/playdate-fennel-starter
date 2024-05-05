(import-macros {: defns} :source.lib.macros)

(tset
 _G.playdate :graphics :animator
 (defns :animator []

   (fn updateTimers [] "TODO")
   ;; Check on args here:
   (fn new [total-time start steps easing delayed] "TODO")))
