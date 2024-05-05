(import-macros {: defns} :source.lib.macros)


(if (not (?. _G.playdate :ui))
    (tset _G.playdate :ui {}))

(if (not (?. _G.playdate.ui :gridview))
    (tset _G.playdate.ui :gridview {}))

(tset
 _G.playdate :ui :gridview
 (defns :gridview []
   (fn new [path] "TODO")))
