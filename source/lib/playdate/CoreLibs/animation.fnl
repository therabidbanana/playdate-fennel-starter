(import-macros {: defns } :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :animation))
    (tset _G.playdate.graphics :animation {}))

(tset
 _G.playdate :graphics :animation
 (defns :animation []
   (local
    blinker
    (defns :blinker []
      (fn updateAll [] "TODO")
      (fn new [] {})
      ))
   (local
    loop
    (defns :loop []
      (fn draw [self x y] (self.image:drawImage self.frame x y))
      (fn isValid [] true)
      (fn new [delay image]
        (let [frame 1]
          { : frame : image : delay : isValid : draw }))
      ))

   (fn updateTimers [] "TODO")
   (fn new [] {})))
