(let []
  (fn add-scene! [$ name scene]
    (doto $ (tset :scenes name scene)))

  (fn load-scenes! [{: scenes &as $} table]
    (tset $ :scenes table)
    $)

  (fn exit-scene! [$ scene]
    (if (and scene (?. scene :exit!)) (scene:exit!))
    (playdate.graphics.sprite.removeAll))

  (fn select! [{: active : scenes &as $} name]
    (if active ($:exit-scene! active))
    (tset $ :active (?. scenes name))
    ($.active:enter!))

  (fn tick! [{: active &as $}]
    (if (and active (?. active :tick!)) (active:tick!)))

  (fn draw! [{: active &as $}]
    (if (and active (?. active :draw!)) (active:draw!)))

  {: add-scene!
   : load-scenes!
   : exit-scene!
   : select!
   : draw!
   : tick!
   :scenes {}})

