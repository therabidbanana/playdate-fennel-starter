(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(pd/import :CoreLibs/ui)
(pd/import :CoreLibs/nineslice)
(pd/import :CoreLibs/animator)
(pd/import :CoreLibs/animation)
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
    (gfx.pushContext)
    (gfx.setDrawOffset 0 0)
    (if view.backgroundImage
        (view.backgroundImage:drawInRect rect)
        (do
          (gfx.setColor gfx.kColorWhite)
          (gfx.fillRoundRect rect 4)
          (gfx.setLineWidth 2)
          (gfx.setColor gfx.kColorBlack)
          (gfx.drawRoundRect rect 4)
          ))
    (if view.nametag
        (view.nametag:draw (+ rect.x 4) (- rect.y 8)))
    (let [text (string.sub (?. view :pages view.currentPageNum) 1 view.chars)
          corner-x (- (+ rect.x rect.w) 14)
          corner-y (- (+ rect.y rect.h) 15)]
      (gfx.drawTextInRect text textRect)
      (view.button:draw corner-x (+ corner-y (if view.blinker.on 1 0)))
      )
    (gfx.popContext)
    )

  (fn build-nametag [{: nametag }]
    (let [name-font (gfx.font.new :assets/fonts/Nontendo-Bold)
          padding 3
          double  (* 2 padding)
          h (name-font:getHeight)
          w (name-font:getTextWidth nametag)
          image (gfx.image.new (+ w (* 2 double)) (+ h double))]
      (gfx.lockFocus image)
      (gfx.setColor gfx.kColorWhite)
      (gfx.fillRoundRect 0 0 (+ w (* 2 double)) (+ h double) 3)
      (gfx.setColor gfx.kColorBlack)
      (gfx.drawRoundRect 0 0 (+ w (* 2 double)) (+ h double) 3)
      (name-font:drawText nametag double padding)
      (gfx.unlockFocus)
      image))

  (fn page-animator [page opts]
    (let [{: per-char : delay?} (or opts {})
          ms-per-char   (or per-char 15)
          chars-in-page (string.len page)
          delay?        (or delay? 0)]
      (playdate.graphics.animator.new
       (* chars-in-page ms-per-char)
       0 chars-in-page
       playdate.easingFunctions.linear
       delay?)))

  (fn tick! [{: view : anim-w : anim-h : anim-text : finished? : action &as comp} $ui]
    (let [pressed? playdate.buttonJustPressed
          selected (?. view.options (view:getSelectedRow))
          lastPage (= (length view.pages) view.currentPageNum)
          finished? (or (anim-text:ended) finished?)
          currPage (?. view.pages view.currentPageNum)
          chars (if finished? (string.len currPage)
                    (math.floor (anim-text:currentValue)))
          justPressedA (pressed? playdate.kButtonA)
          next-page (+ view.currentPageNum 1)]
      (if anim-h
          (set comp.rect.height (anim-h:currentValue)))
      (if anim-w
          (set comp.rect.width (anim-w:currentValue)))
      (if (and justPressedA finished?)
            (if lastPage
                (do
                  ($ui:pop-component!)
                  (if action (action)))
                (do
                  (tset comp :finished? false)
                  (tset comp.view :currentPageNum next-page)
                  (tset comp :anim-text (page-animator (?. view.pages next-page)))
                  (tset comp.view :chars 0)))
          justPressedA
          (tset comp :finished? true)
          chars
          (tset comp.view :chars chars))))

  (fn new! [proto $ui {: text : nametag : x : y : w : h : animate-in? : action : padding}]
    (let [frame (playdate.ui.gridview.new 0 10)
          padding-top (or padding 10)
          padding (or padding 8)
          rect (playdate.geometry.rect.new (or x 5) (or y 156)
                                           (if animate-in? 0 w w 390)
                                           (if animate-in? 0 h h 82))
          textRect (rect:insetBy padding padding-top)
          _ (if nametag (tset textRect :y (+ textRect.y 4)))
          anim-w (if animate-in?
                     (playdate.graphics.animator.new 150 10 (or w 380) playdate.easingFunctions.easeOutCubic))
          anim-h (if animate-in?
                     (playdate.graphics.animator.new 150 10 (or h 120) playdate.easingFunctions.easeOutCubic))
          blinker (doto (playdate.graphics.animation.blinker.new) (: :start 800 300 true))
          button (gfx.image.new :assets/images/button-a)
          pages (-paginated-string text textRect)
          chars-per-page (string.len (?. pages 1))
          anim-text (page-animator (?. pages 1) {:delay? (if animate-in? 150 0)})
          ;; bg (gfx.nineSlice.new :assets/images/scrollbg 8 14 100 36)
          bg nil
          finished? false
          nametag (if nametag (build-nametag {: nametag}))
          view {:backgroundImage bg : nametag : pages :currentPageNum 1 :chars 0 : blinker : button}]
      (table.shallowcopy proto {: view : rect : textRect : anim-w : anim-h : anim-text : action : finished?}))
    )
  )
