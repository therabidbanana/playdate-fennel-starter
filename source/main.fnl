;; Patch for missing require, weird import
(print "Installing fake require & import support...")
(global package {:loaded {} :preload {}})
(fn _G.require [name] 
  (if (not (. package.loaded name))
    (tset package.loaded name ((?. package.preload name))))
  (?. package.loaded name))
(macro pd/import [lib] `(lua ,(.. "import \"" lib "\"")))
;; End patch for missing require, weird import

(pd/import "CoreLibs/object")
(pd/import "CoreLibs/graphics")
(pd/import "CoreLibs/sprites")
(pd/import "CoreLibs/timer")
(pd/import "CoreLibs/ui")
(pd/import "CoreLibs/nineslice")


(let [{: scenes} (require :source.lib.core)
      {:player player-ent} (require :source.game.entities.core)
      pd playdate
      gfx pd.graphics
      blocky (gfx.getSystemFont)]

  (var listview nil)
  (local scene
         {:enter! (fn scene-enter! [$]
                    (var player nil)
                    (set player (player-ent.new! 20 20))
                    (player:add)
                    )
          :exit! (fn scene-exit! [$]
                   )
          :tick! (fn scene-tick! [$]
                   ;; (listview:drawInRect 180 20 200 200)
                   (pd.timer.updateTimers)
                   (gfx.sprite.performOnAllSprites
                     (fn react-each [ent] (if (?. ent :react!) (ent:react!))))
                   )
          :draw! (fn scene-tick! [$]
                   (gfx.sprite.update)
                   (pd.drawFPS 20 20)
                   ;; (listview:drawInRect 180 20 200 200)
                   (pd.timer.updateTimers)
                   )})

  (fn testScroll []
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

  (fn setupGame []
    (scene:enter!)
    ;; (set listview (testScroll))
    )

  (setupGame)

  (fn pd.update []
    (scene:tick!)
    (scene:draw!)
    ))
