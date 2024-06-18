(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(defmodule _G.playdate.graphics
  [font (require :source.lib.playdate.CoreLibs.font)
   imagetable (require :source.lib.playdate.CoreLibs.imagetable)
   tilemap (require :source.lib.playdate.CoreLibs.tilemap)
   ]
  (local default-font (love.graphics.newFont "assets/fonts/AshevilleBM.fnt"))
  (local current-font default-font)
  (local COLOR_WHITE { :r (/ 176 255) :g (/ 174 255) :b (/ 167 255) })
  (local COLOR_BLACK { :r (/ 49  255) :g (/ 47  255) :b (/ 40  255)  })
  (local kColorBlack COLOR_BLACK)
  (local kColorWhite COLOR_WHITE)
  (local kDrawModeCopy "copy")
  (local kDrawModeFillWhite "fillwhite")
  (local kDrawModeFillBlack "fillblack")
  (local _mode kDrawModeCopy)

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
  (fn setColor [color]
    (love.graphics.setColor color.r color.g color.b)
    )
  (fn fillRoundRect [x y width height radius]
    (if (= nil width)
        (love.graphics.rectangle "fill" x.x x.y x.width x.height radius radius)
        (love.graphics.rectangle "fill" x y width height radius radius)))
  (fn setLineWidth [width] "todo")
  (fn drawRoundRect [rect radius]
    (if (= nil width)
        (love.graphics.rectangle "line" x.x x.y x.width x.height radius radius)
        (love.graphics.rectangle "line" x y width height radius radius))
    "todo")
  (fn lockFocus [canvas] "todo")
  ;; (name-font:drawText nametag double padding)
  (fn unlockFocus [] "TODO")
  (fn setImageDrawMode [mode]
    (let [_shader (love.graphics.getShader)]
      (tset _G.playdate.graphics :_mode mode)
      (if (= kDrawModeCopy mode)
          (_shader:send "mode" 0)
          (= kDrawModeFillWhite mode)
          (_shader:send "mode" 1)
          (= kDrawModeFillBlack mode)
          (_shader:send "mode" 2))))

  (love.graphics.setFont default-font)
  )
