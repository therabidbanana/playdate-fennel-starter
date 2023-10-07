(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(pd/import :CoreLibs/ui)
(pd/import :CoreLibs/nineslice)
(pd/import :CoreLibs/animator)
(pd/import :CoreLibs/easing)


(defns :source.lib.ui.textbox
  [gfx playdate.graphics]

  (fn -words-fit? [rect arr]
    (let [(w h) (gfx.getTextSizeForMaxWidth (table.concat arr " ") rect.w)]
      (and (<= h rect.h) (<= w rect.w))))

  (fn -words [str]
    (local acc [])
    (each [v (string.gmatch str "[^ \t]+")]
      (table.insert acc v))
    acc)

  (fn -paginated-string [str rect]
    (let [pages [[]]
          words (-words str)]
      (each [_ word (ipairs words)]
        (let [currPage (length pages)
              newPage (table.shallowcopy (or (?. pages currPage) []))]
          (table.insert newPage word)
          (if (-words-fit? rect newPage)
              (table.insert (?. pages currPage) word)
              (table.insert pages [word]))))
      (icollect [_ v (ipairs pages)]
        (table.concat v " ")))
    )

  (fn render! [{: view : rect : textRect &as comp} $ui]
    ;; needsDisplay note - sprite update sometimes wipes area
    (if view.backgroundImage
        (view.backgroundImage:drawInRect rect)
        (do
          (gfx.setColor gfx.kColorWhite)
          (gfx.fillRoundRect rect 4)
          (gfx.setLineWidth 2)
          (gfx.setColor gfx.kColorBlack)
          (gfx.drawRoundRect rect 4)))
    (let [text (string.sub (?. view :pages view.currentPageNum) 1 view.chars)]
      (gfx.drawTextInRect text textRect)))

  (fn tick! [{: view : anim-w : anim-h : anim-text : finished? &as comp} $ui]
    (let [pressed? playdate.buttonJustPressed
          selected (?. view.options (view:getSelectedRow))
          lastPage (= (length view.pages) view.currentPageNum)
          finished? (or (anim-text:ended) finished?)
          currPage (?. view.pages view.currentPageNum)
          chars (if finished? (string.len currPage)
                    (math.floor (anim-text:currentValue)))
          justPressedA (pressed? playdate.kButtonA)]
      (if anim-h
          (set comp.rect.height (anim-h:currentValue)))
      (if anim-w
          (set comp.rect.width (anim-w:currentValue)))
      (if (and justPressedA finished?)
            (if lastPage
                ($ui:pop-component!)
                (do
                  (comp.anim-text:reset)
                  (tset comp :finished? false)
                  (tset comp.view :currentPageNum (+ view.currentPageNum 1))
                  (tset comp.view :chars 0)))
          justPressedA
          (tset comp :finished? true)
          chars
          (tset comp.view :chars chars))))

  (fn new! [proto $ui {: text : x : y : w : h : animate-in? : padding}]
    (let [frame (playdate.ui.gridview.new 0 10)
          padding (or padding 8)
          padding-top (or padding 10)
          rect (playdate.geometry.rect.new (or x 5) (or y 140)
                                           (if animate-in? 0 w w 390)
                                           (if animate-in? 0 h h 98))
          textRect (rect:insetBy padding padding-top)
          anim-w (if animate-in?
                     (playdate.graphics.animator.new 150 10 (or w 380) playdate.easingFunctions.easeOutCubic))
          anim-h (if animate-in?
                     (playdate.graphics.animator.new 150 10 (or h 120) playdate.easingFunctions.easeOutCubic))
          pages (-paginated-string text textRect)
          chars-per-page (string.len (?. pages 1))
          anim-text (playdate.graphics.animator.new (* chars-per-page 15)
                                                    0 chars-per-page
                                                    playdate.easingFunctions.linear
                                                    ;; Delay for box animation
                                                    (if animate-in? 150 0))
          ;; bg (gfx.nineSlice.new :assets/images/scrollbg 8 14 100 36)
          bg nil
          finished? false
          view {:backgroundImage bg : pages :currentPageNum 1 :chars 0}]
      (table.shallowcopy proto {: view : rect : textRect : anim-w : anim-h : anim-text : finished?}))
    )
  )
