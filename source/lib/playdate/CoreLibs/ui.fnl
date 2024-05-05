(import-macros {: defns} :source.lib.macros)

(if (not (?. _G.playdate :ui))
    (tset _G.playdate :ui {}))

(tset
 _G.playdate :ui
 (defns :ui []
   ))
