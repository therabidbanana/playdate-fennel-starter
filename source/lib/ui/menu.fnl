(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(pd/import :CoreLibs/ui)
(pd/import :CoreLibs/nineslice)
(pd/import :CoreLibs/animator)
(pd/import :CoreLibs/easing)

(defns :source.lib.ui.menu
  [pd playdate
   gfx playdate.graphics]

  (fn -draw-cell [{: options &as view}
                  section
                  row
                  column
                  selected
                  x
                  y
                  width
                  height]
    (if selected
        (do
          (gfx.setColor gfx.kColorBlack)
          (gfx.fillRoundRect x y width height 4)
          (gfx.setColor gfx.kColorWhite)
          (gfx.setImageDrawMode gfx.kDrawModeFillWhite))
        (do
          (gfx.setColor gfx.kColorWhite)
          (gfx.fillRoundRect x y width height 4)
          (gfx.setImageDrawMode gfx.kDrawModeCopy)))
    (gfx.drawTextInRect (?. options row :text) (+ x 4) (+ y 4) (- width 8)
                        height nil))

  (fn -handle-click [{: action : keep-open?} $ui]
    (if (not keep-open?) ($ui:pop-component!))
    (if action (action)))

  (fn render! [{: view : rect : on-draw &as comp} $ui]
    (if on-draw (on-draw comp (?. view.options (view:getSelectedRow))))
    ;; needsDisplay note - sprite update sometimes wipes area
    (view:drawInRect (rect:unpack))
    )

  (fn tick! [{: view : anim-w : anim-h &as comp} $ui]
    (let [pressed? playdate.buttonJustPressed
          selected (?. view.options (view:getSelectedRow))]
      (if anim-h
          (tset comp.rect :height (math.floor (anim-h:currentValue))))
      (if anim-w
          (tset comp.rect :width (math.floor (anim-w:currentValue))))
      (if (and anim-h (anim-h:ended)) (tset comp :anim-h nil))
      (if (and anim-w (anim-w:ended)) (tset comp :anim-w nil))
      (if (pressed? playdate.kButtonDown) (view:selectNextRow)
          (pressed? playdate.kButtonUp) (view:selectPreviousRow)
          (pressed? playdate.kButtonA) (-handle-click selected $ui))))

  (fn new! [proto $ui {: options : x : y : w : h : animate? : on-draw}]
    (let [view (playdate.ui.gridview.new 0 10)
          rect (playdate.geometry.rect.new (or x 10) (or y 10)
                                           (if animate? 0 w w 180)
                                           (if animate? 0 h h 220))
          anim-w (if animate?
                     (playdate.graphics.animator.new 150 10 (or w 180) playdate.easingFunctions.easeOutCubic))
          anim-h (if animate?
                     (playdate.graphics.animator.new 150 10 (or h 220) playdate.easingFunctions.easeOutCubic))
          bg (gfx.nineSlice.new :assets/images/scrollbg 8 14 100 36)]
      (doto view
        (tset :backgroundImage bg)
        (tset :options options)
        (tset :drawCell -draw-cell)
        (: :setNumberOfRows (length options))
        (: :setCellPadding 0 0 5 4)
        (: :setCellSize 0 24)
        (: :setContentInset 8 8 12 11))
      (table.shallowcopy proto {: view : rect : anim-w : anim-h : on-draw}))
    )
  )

