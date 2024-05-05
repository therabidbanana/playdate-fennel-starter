(import-macros {: defns } :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :animation))
    (tset _G.playdate.graphics :animation {}))

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
