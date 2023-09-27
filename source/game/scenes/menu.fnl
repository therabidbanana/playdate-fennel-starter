(import-macros {: inspect } :source.lib.macros)

(fn testScroll [pd gfx]
  (local menu-options [:Sword
                       :Shield
                       :Arrow
                       :Sling
                       :Stone
                       :Longbow
                       :MorningStar
                       :Armour
                       :Dagger
                       :Rapier
                       :Skeggox
                       "War Hammer"
                       "Battering Ram"
                       :Catapult])
  (local listview (playdate.ui.gridview.new 0 10))
  (set listview.backgroundImage
       (playdate.graphics.nineSlice.new :assets/images/scrollbg 20 23 92 28))
  (listview:setNumberOfRows (length menu-options))
  (listview:setCellPadding 0 0 5 4)
  (listview:setCellSize 0 20)
  (listview:setContentInset 24 24 13 11)
  (listview:selectNextRow)
  (fn listview.drawCell [self section row column selected x y width height]
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
    (gfx.drawTextInRect (?. menu-options row) (+ x 2) (+ y 2) (- width 4) height nil)
    ;; (blocky:drawText (.. width "x" height " at " x "," y) x y)
    )
  listview)

(let [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      pd playdate
      gfx pd.graphics]

  {:enter! (fn scene-enter! [$]
             (tset $ :state :listview (testScroll pd gfx))
             )
   :state {}
   :exit! (fn scene-exit! [$]
            (tset $ :state {}))
   :tick! (fn scene-tick! [{:state {: listview } &as $}]
            ;; (listview:drawInRect 180 20 200 200)
            (let [pressed? playdate.buttonJustPressed]
              (if (pressed? playdate.kButtonDown)
                  (listview:selectNextRow)
                  (pressed? playdate.kButtonUp)
                  (listview:selectPreviousRow)
                  (pressed? playdate.kButtonA)
                  (scene-manager:select! :title)
                  )
              )
            (pd.timer.updateTimers)
            (gfx.sprite.performOnAllSprites
             (fn react-each [ent] (if (?. ent :react!) (ent:react!))))
            )
   :draw! (fn scene-tick! [{:state {: listview } &as $}]
            (gfx.sprite.update)
            (pd.drawFPS 20 20)
            (listview:drawInRect 180 20 200 200)
            (pd.timer.updateTimers)
            )
   })
