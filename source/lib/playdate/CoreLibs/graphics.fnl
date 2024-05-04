(import-macros {: defns} :source.lib.macros)

(tset
 _G.playdate :graphics
 (defns :graphics [font (require :source.lib.playdate.CoreLibs.font)]
   (local default-font (love.graphics.newFont "assets/fonts/AshevilleBM.fnt"))
   (local current-font default-font)
   (fn getDisplayImage [] "TODO")
   (fn clear [] "TODO")
   (fn getTextSizeForMaxWidth [text max-w]
     (let [curr-font (love.graphics.getFont)
           (w lines) (curr-font:getWrap text max-w)]
       (values w (* (curr-font:getLineHeight) (length lines)))
       ))
   (fn drawTextInRect [text x y w h]
     (let [curr-font (love.graphics.getFont)]
       (love.graphics.printf text x y w))
     )

   (love.graphics.setFont default-font)
   ))
