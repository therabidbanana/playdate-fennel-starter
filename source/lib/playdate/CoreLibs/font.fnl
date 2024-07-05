(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate :graphics :font))
    (tset _G.playdate :graphics :font {}))

(defmodule _G.playdate.graphics.font []

  (fn getHeight [self]
    (self.fnt:getHeight))

  (fn getTextWidth [self text]
    (let [(w lines) (self.fnt:getWrap text 400)]
      w))

  (fn drawText [self text x y]
    (love.graphics.push :all)
    (love.graphics.setFont self.fnt)
    (love.graphics.printf text x y (getTextWidth self text))
    (love.graphics.pop)
    )

  (fn new [path]
    (let [full-path (.. path ".bmfnt")
          fnt (love.graphics.newFont full-path)]
      {: fnt : getHeight : getTextWidth : drawText })
    ))
