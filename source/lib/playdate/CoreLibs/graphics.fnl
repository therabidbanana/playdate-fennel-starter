(import-macros {: defns} :source.lib.macros)
(tset
 _G.playdate :graphics
 (defns :graphics []
   (fn getDisplayImage [] "TODO")
   (fn clear [] "TODO")
   (fn drawTextInRect [text x y ...]
     (love.graphics.print text x y))
   ))
