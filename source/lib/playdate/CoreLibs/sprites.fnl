(import-macros {: defns} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :sprite))
    (tset _G.playdate.graphics :sprite {}))

(tset
 _G.playdate :graphics :sprite
 (defns :sprite []
   (fn update [] "TODO")
   (fn removeAll [] "TODO")))
