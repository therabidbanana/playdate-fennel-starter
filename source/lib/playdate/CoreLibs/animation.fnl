(import-macros {: inspect : defns } :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :animation))
    (tset _G.playdate.graphics :animation {}))

(tset
 _G.playdate :graphics :animation
 (defns :animation
   [timer-lib _G.playdate.timer]
   (local
    blinker
    (defns :blinker []
      (fn start [] "TODO")
      (fn updateAll [] "TODO")
      (fn new [] {: start}
        )
      ))
   (local
    loop
    (defns :loop []
      (fn draw [$ x y]
        (let []
          ;; TODO: can we do this state tweaking outside the draw loop? there's no animation.loop updateAll...
          (if (and $.timer.expired (< (+ $.__frame $.startFrame) $.endFrame))
              (do
                ($.timer:reset)
                (tset $ :__frame (+ $.__frame 1)))
              (and $.timer.expired $.shouldLoop)
              (do
                ($.timer:reset)
                (tset $ :__frame 0))
              $.timer.expired
              (do
                ($.timer:reset)
                (tset $ :finished true))
              true
              (do
                (tset $ :finished false)
                ;; (tset $ :frame (math.min $.frame $.startFrame))
                )
              )
          ($.image:drawImage (+ $.startFrame $.__frame) x y)))

      (fn isValid [self]
        (if self.finished
            false
            (or self.shouldLoop
                (> self.endFrame (+ self.__frame self.startFrame))
                (> self.timer.timeLeft 0))))

      (fn remove [self]
        (self.timer:remove))

      (fn new [delay image shouldLoop]
        (let [__frame 0
              __state {}
              startFrame 1
              endFrame (length image.quads)
              finished false
              shouldLoop (if (= shouldLoop nil) true shouldLoop)
              timer (timer-lib.new delay)
              item { : startFrame : endFrame : __frame : finished
                     : shouldLoop : timer : __state
                     : image : delay : isValid : draw : remove }]
          (tset timer :discardOnCompletion false)
          (setmetatable item {:__index (fn [tbl key]
                                         (if (= :paused key)
                                             tbl.timer.paused
                                             (= :frame key)
                                             tbl.__frame
                                             (. tbl.__state key)))
                              :__newindex (fn [tbl key val]
                                            (if (= :paused key)
                                                (tset tbl.timer :paused val)
                                                (= :frame key)
                                                (do
                                                  (tset tbl :__frame (- val 1))
                                                  (tset tbl :finished false)
                                                  (tbl.timer:reset))
                                                (tset tbl.__state key val)))}))
        )

      ))

   (fn new [] {})))
