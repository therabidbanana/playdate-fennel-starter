(let []
  (fn add-scene! [$ name scene]
    (doto $ (tset :scenes name scene)))

  (fn load-scenes! [{: scenes &as $} table]
    (tset $ :scenes table)
    $)

  (fn select! [{: active : scenes &as $} name]
    (if (and active (?. active :exit!)) (active:exit!))
    (tset $ :active (?. scenes name))
    ($.active:enter!))

  (fn tick! [{: active &as $}]
    (if (and active (?. active :tick!)) (active:tick!)))

  (fn draw! [{: active &as $}]
    (if (and active (?. active :draw!)) (active:draw!)))

  {: add-scene!
   : load-scenes!
   : select!
   : draw!
   : tick!
   :scenes {}
   })
