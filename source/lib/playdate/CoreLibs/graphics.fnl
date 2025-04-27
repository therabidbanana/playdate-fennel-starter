(import-macros {: defmodule : inspect : div} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(defmodule _G.playdate.graphics
  [font (require :source.lib.playdate.CoreLibs.font)
   imagetable (require :source.lib.playdate.CoreLibs.imagetable)
   tilemap (require :source.lib.playdate.CoreLibs.tilemap)
   image (require :source.lib.playdate.CoreLibs.image)
   love-wrap (require :source.lib.playdate.CoreLibs.love-wrap)
   ]
  (local default-font (font.new :assets/fonts/Asheville))
  (local current-font default-font)
  (local COLOR_WHITE { :r (/ 176 255) :g (/ 174 255) :b (/ 167 255) })
  (local COLOR_BLACK { :r (/ 49  255) :g (/ 47  255) :b (/ 40  255)  })
  (local COLOR_DEBUG { :r (/ 255  255) :g (/ 12  255) :b (/ 12  255)  })
  (local kColorBlack COLOR_BLACK)
  (local kColorWhite COLOR_WHITE)
  (local kDrawModeCopy "copy")
  (local kDrawModeFillWhite "fillWhite")
  (local kDrawModeFillBlack "fillBlack")
  (local _mode kDrawModeCopy)
  (local _tx 0)
  (local _ty 0)
  (local strings {})

  (fn getDisplayImage []
    (image.new _G.playdate._last-image)
    )

  (fn setImageDrawMode [mode]
    (let [_shader (love.graphics.getShader)]
      (if _shader
          (do
            (tset _G.playdate.graphics :_mode mode)
            (if (= kDrawModeCopy mode)
                (_shader:send "mode" 0)
                (= kDrawModeFillWhite mode)
                (_shader:send "mode" 1)
                (= kDrawModeFillBlack mode)
                (_shader:send "mode" 2))))))

  (fn -read-strings [strings lang]
    (let [file (love.filesystem.read (.. lang ".strings"))]
      (tset strings lang {})
      (each [k v (string.gmatch file "\"([^\"]+)\"%s*=%s*\"([^\"]+)\"")]
        (tset strings lang k (v:gsub "\\n" "\n")))
      ))

  (fn getLocalizedText [key lang]
    (let [lang (or lang "en")]
      (if (?. strings lang)
          (?. strings lang key)
          (do (-read-strings strings lang)
              (?. strings lang key))))
    )

  (fn clear [] (love.graphics.clear))
  (local graphics-stack [])

  (fn setDrawOffset [x y]
    (_G.love-wrap.set-offset! x y)
    ;; (tset _G.love-wrap :tx x)
    ;; (tset _G.love-wrap :ty y)
    ;; (love.graphics.translate x y)
    )
  (fn pushContext [image?]
    (let [curr-context {:mode  _mode
                        :tx    _G.love-wrap.state.tx
                        :ty    _G.love-wrap.state.ty}]
      ;; TODO - handle set canvas
      (table.insert graphics-stack curr-context)
      (love.graphics.push :all)
      ))

  (fn popContext []
    (let [prev-context (table.remove graphics-stack)
          _shader (love.graphics.getShader)]
      (if prev-context
          (do
            (love.graphics.pop)
            (setImageDrawMode prev-context.mode)
            (setDrawOffset prev-context.tx prev-context.ty)
            ))
      ))

  (fn getTextSizeForMaxWidth [text max-w]
    (let [curr-font (love.graphics.getFont)
          (w lines) (curr-font:getWrap text max-w)]
      (values w (* (curr-font:getHeight) (length lines)))
      ))
  (fn drawTextInRect [text & rest]
    (let [curr-font (love.graphics.getFont)]
      (case rest
        [{: x : y : w &as rect}] (love-wrap.printf text x y w)
        [x y w h] (love-wrap.printf text x y w)
        )
      ;; (love.graphics.printf text x y w)
      )
    )

  (fn drawText [text & rest]
    (let [curr-font (love.graphics.getFont)]
      (case rest
        [{: x : y &as rect}] (love-wrap.printf text x y w)
        [x y] (love-wrap.printf text x y 400)
        )
      ;; (love.graphics.printf text x y w)
      )
    )

  (fn setColor [color]
    (tset _G.playdate.graphics :_fg color)
    ;; (love.graphics.setColor color.r color.g color.b (?. color :a))
    )

  (fn setBackgroundColor [color]
    (tset _G.playdate.graphics :_bg color)
    ;; (love.graphics.setColor color.r color.g color.b (?. color :a))
    )

  (fn fillRoundRect [& rest]
    (do
      (love.graphics.push :all)
      (love.graphics.setColor _G.playdate.graphics._fg.r
                              _G.playdate.graphics._fg.g
                              _G.playdate.graphics._fg.b)
      (case rest
        [x y width height radius]
        (love-wrap.rectangle "fill" x y width height radius radius)
        [{: x : y : width : height : h : w} radius]
        (love-wrap.rectangle "fill" x y (or width w) (or height h) radius radius)
        )
      (love.graphics.pop)
      )
    )

  (fn setLineWidth [width]
    (love.graphics.setLineWidth (- width 1)))

  (fn drawRoundRect [& rest]
    (love.graphics.push :all)
    (love.graphics.setColor _G.playdate.graphics._fg.r
                            _G.playdate.graphics._fg.g
                            _G.playdate.graphics._fg.b)
    (case rest
      [x y width height radius]
      (love-wrap.rectangle "line" x y width height radius radius)
      [{: x : y : width : height : w : h} radius]
      (love-wrap.rectangle "line" x y (or width w) (or height h) radius radius)
      )
    (love.graphics.pop))

  (fn drawLine [x1 y1 x2 y2]
    (love.graphics.push :all)
    ;; (love.graphics.setLineWidth 2)
    (love.graphics.setColor _G.playdate.graphics._fg.r
                            _G.playdate.graphics._fg.g
                            _G.playdate.graphics._fg.b)
    (love.graphics.line x1 y1 x2 y2)
    (love.graphics.pop))

  (fn drawCircleInRect [& rest]
    (love.graphics.push :all)
    (love.graphics.setColor _G.playdate.graphics._fg.r
                            _G.playdate.graphics._fg.g
                            _G.playdate.graphics._fg.b)
    (case rest
      [x y width height]
      (let [x-rad (div width 2)
            y-rad (div height 2)]
        (love.graphics.ellipse "line" (+ x x-rad) (+ y y-rad)
                               x-rad y-rad))
      [{: x : y : width : height}]
      (let [x-rad (div width 2)
            y-rad (div height 2)]
        (love.graphics.ellipse "line" (+ x x-rad) (+ y y-rad)
                               x-rad y-rad)))
    (love.graphics.pop)
    )

  (fn lockFocus [canvas]
    (love.graphics.push :all)
    (if (?. canvas :image)
        (love.graphics.setCanvas canvas.image)
        )
    )

  (fn unlockFocus []
    (love.graphics.pop)
    )
  
  (fn getImageDrawMode [mode]
    _G.playdate.graphics._mode)

  (love.graphics.setFont default-font.fnt)
  )
