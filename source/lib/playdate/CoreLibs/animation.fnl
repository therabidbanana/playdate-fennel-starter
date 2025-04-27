(import-macros {: inspect : defmodule : defns } :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :animation))
    (tset _G.playdate.graphics :animation {}))

(defmodule _G.playdate.graphics.animation
  [timer-lib _G.playdate.timer]
  (local blinker {})
  (local loop {})

  (fn new [] {}))

(defmodule _G.playdate.graphics.animation.loop
  [timer-lib _G.playdate.timer]
  (fn -tick-timer! [$]
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
        ))
  (fn draw [$ x y]
    (let []
      ;; TODO: can we do this state tweaking outside the draw loop? there's no animation.loop updateAll...
      ($:-tick-timer!)
      ($._image:drawImage (+ $.startFrame $.__frame) x y)))

  (fn isValid [self]
    (if self.finished
        false
        (or self.shouldLoop
            (> self.endFrame (+ self.__frame self.startFrame))
            (> self.timer.timeLeft 0))))

  (fn remove [self]
    (self.timer:remove))

  (fn image [self]
    (self:-tick-timer!)
    (self._image:getImage (+ self.startFrame self.__frame)))

  (fn new [delay _image shouldLoop]
    (let [__frame 0
          __state {}
          startFrame 1
          endFrame (length _image.quads)
          finished false
          shouldLoop (if (= shouldLoop nil) true shouldLoop)
          timer (timer-lib.new delay)
          item { : startFrame : endFrame : __frame : finished
                 : shouldLoop : timer : __state : -tick-timer!
                 : _image : image : delay : isValid : draw : remove }]
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
    ))

(defmodule _G.playdate.graphics.animation.blinker []
  (local timer-state {:all-timers []})

  (fn start [self on-ms off-ms loop cycles on-val]
    (tset self :running true)
    (if (not= on-ms nil) (tset self :on-ms on-ms))
    (if (not= off-ms nil) (tset self :off-ms off-ms))
    (if (not= loop nil) (tset self :loop loop))
    (if (not= cycles nil)
        (tset self :cycles cycles)
        (tset self :cycles self.max-cycles))
    (if (not= on-val nil) (tset self :on-val on-val))
    (if (not= on-val nil) (tset self :off-val (not on-val)))
    self)

  (fn stop [self]
    (tset self :state :on)
    (tset self :running false)
    (tset self :cycles 0)
    (tset self :on self.on-val)
    self)

  (fn remove [self]
    (tset self :discarded true)
    self)

  (fn advance [self dt]
    (if self.running
        (let [time-left (- self.time-left dt)
              flip? (< time-left 0)
              reduced-cycles (- self.cycles 1)]
          (if (and flip? (< reduced-cycles 0) (not self.loop))
              (do
                (tset self :running false)
                (tset self :time-left 0)
                (tset self :cycles 0)
                (tset self :state (case self.state :on :off :off :on))
                (tset self :on (case self.state :on self.off-val :off self.on-val))
                )
              flip?
              (do
                (if (not self.loop)
                    (tset self :cycles reduced-cycles))
                (tset self :state (case self.state :on :off :off :on))
                (tset self :on (case self.state :on self.off-val :off self.on-val))
                (tset self :time-left (+ time-left (case self.state :on self.off-ms :off self.on-ms)))
                )
              (tset self :time-left time-left))
          )
        self)
    )

  (fn updateAll []
    (let [dt (math.floor (* (love.timer.getDelta) 1000))]
      (each [i timer (ipairs timer-state.all-timers)]
        (advance timer dt))
      (tset timer-state :all-timers
            (icollect [i timer (ipairs timer-state.all-timers)]
              (if timer.discarded nil timer)))
      )
    )

  (fn new [on-ms off-ms loop cycles on-val]
    (let [on-ms (or on-ms 200)
          off-ms (or off-ms 200)
          loop (or loop false)
          cycles (or cycles 6)
          on-val (if (not= on-val nil) on-val true)
          off-val (not on-val)
          timer {: cycles : on-val : on-ms : off-ms : off-val
                 :max-cycles cycles :running false :state :on
                 :time-left on-ms :discarded false
                 : start : remove : stop}]
      (table.insert timer-state.all-timers timer)
      timer)
    )
  )

_G.playdate.graphics.animation
