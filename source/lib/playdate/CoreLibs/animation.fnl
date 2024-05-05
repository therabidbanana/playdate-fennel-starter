(import-macros {: defns } :source.lib.macros)

(tset
 _G.playdate :graphics :animation
 (defns :animation []
   (local
    blinker
    (defns :blinker []
      (fn updateAll [] "TODO")
      (fn new [] "TODO")
      ))

   (fn updateTimers [] "TODO")))
