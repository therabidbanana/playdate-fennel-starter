(let [gfx playdate.graphics
      timer playdate.timer
      sprite gfx.sprite]
  (fn add-scene! [$ name scene]
    (doto $ (tset :scenes name scene)))

  (fn load-scenes! [{: scenes &as $} table]
    (tset $ :scenes table)
    $)

  (fn exit-scene! [$ scene]
    (if (and scene (?. scene :exit!)) (scene:exit!))
    (sprite.removeAll))

  (fn select! [{: active : scenes &as $} name]
    (if active ($:exit-scene! active))
    (tset $ :active (?. scenes name))
    ($.active:enter!))

  (fn tick! [{: active &as $}]
    (if (and active (?. active :tick!)) (active:tick!))
    (timer.updateTimers)
    )

  (fn draw! [{: active &as $}]
    (sprite.update)
    (if $config.debug (playdate.drawFPS 20 20))
    (if (and active (?. active :draw!)) (active:draw!))
    )

  {: add-scene!
   : load-scenes!
   : exit-scene!
   : select!
   : draw!
   : tick!
   :scenes {}})

