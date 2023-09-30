(import-macros {: defns : pd/import} :source.lib.macros)

(pd/import :CoreLibs/ui)
(pd/import :CoreLibs/nineslice)

(defns :source.lib.ui.menu
  [pd playdate gfx playdate.graphics]

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
    (gfx.drawTextInRect (?. options row :text) (+ x 2) (+ y 2) (- width 4)
                        height nil))

  (fn -handle-click [{: action : keep-open?} $ui]
    (if action (action))
    (if (not keep-open?) ($ui:pop-component!)))

  (fn render! [{: view &as comp} $ui]
    ;; needsDisplay note - sprite update sometimes wipes area
    (view:drawInRect 180 20 200 200))

  (fn tick! [{: view &as comp} $ui]
    (let [pressed? playdate.buttonJustPressed
          selected (?. view.options (view:getSelectedRow))]
      (if (pressed? playdate.kButtonDown) (view:selectNextRow)
          (pressed? playdate.kButtonUp) (view:selectPreviousRow)
          (pressed? playdate.kButtonA) (-handle-click selected $ui))))

  (fn new! [proto $ui {: options}]
    (let [view (playdate.ui.gridview.new 0 10)
          bg (gfx.nineSlice.new :assets/images/scrollbg 8 14 100 36)]
      (doto view
        (tset :backgroundImage bg)
        (tset :options options)
        (tset :drawCell -draw-cell)
        (: :setNumberOfRows (length options))
        (: :setCellPadding 0 0 5 4)
        (: :setCellSize 0 40)
        (: :setContentInset 8 8 12 11))
      (table.shallowcopy proto {: view}))))

