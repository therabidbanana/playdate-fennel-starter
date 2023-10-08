(let [gfx playdate.graphics
      timer playdate.timer
      sprite gfx.sprite]
  (fn add-scene! [$ name scene]
    (doto $ (tset :scenes name scene)))

  (fn load-scenes! [{: scenes &as $} table]
    (tset $ :scenes table)
    $)

  (fn exit-scene! [$ scene]
    (tset $ :last-screen (gfx.getDisplayImage))
    (tset $ :fade-out-anim (playdate.graphics.animator.new 250 0 -400 playdate.easingFunctions.easeOutCubic))
    (gfx.clear)
    (if (and scene (?. scene :exit!)) (scene:exit!))
    (sprite.removeAll)
    )

  (fn select! [{: active : scenes &as $} name]
    (if active ($:exit-scene! active))
    (tset $ :active (?. scenes name))
    ($.active:enter!))

  (fn tick! [{: active &as $}]
    (if (and active (?. active :tick!)) (active:tick!))
    (timer.updateTimers)
    )

  (fn draw! [{: active : fade-out-anim : last-screen &as $}]
    (sprite.update)
    (if $config.debug (playdate.drawFPS 20 20))
    (if (and active (?. active :draw!)) (active:draw!))
    (if (and fade-out-anim (fade-out-anim:ended))
        (do
          (tset $ :fade-out-anim nil)
          (tset $ :last-screen nil))
        (and fade-out-anim last-screen)
        ;; Transition by sliding left
        (last-screen:draw (fade-out-anim:currentValue) 0)
        )
    )

  {: add-scene!
   : load-scenes!
   : exit-scene!
   : select!
   : draw!
   : tick!
   :scenes {}})

