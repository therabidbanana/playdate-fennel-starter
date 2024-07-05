(import-macros {: defns : inspect} :source.lib.macros)

(tset
 _G.playdate :timer
 (defns :timer [
                easing _G.playdate.easingFunctions]
   (local timer-state {:all-timers []})
   (fn reset [self]
     (tset self :currentTime 0)
     (tset self :value self.startValue)
     (tset self :timeLeft self.duration)
     (tset self :expired false)
     (tset self :discarded false)
     )

   (fn advance [$ dt]
     (if $.discarded
         $
         $.paused
         $
         $.expired
         $
         (let [newTime (math.min (+ dt $.currentTime) $.duration)
               newLeft (math.max (- $.timeLeft dt) 0)
               expired (>= newTime $.duration)
               easeFn  $.easingFunction
               newVal  (easeFn newTime $.startValue (- $.endValue $.startValue) $.duration)
               ]
           (if (and expired $.reverses)
               (doto $
                 (tset :value $.endValue)
                 (tset :endValue $.startValue)
                 (tset :startValue $.startValue)
                 (tset :timeLeft $.duration)
                 (tset :expired false)
                 (tset :currentTime 0)
                 )
               expired
               (do
                 (doto $
                  (tset :expired true)
                  (tset :value $.endValue)
                  (tset :discarded $.discardOnCompletion)))
               ;; else
               (doto $
                 (tset :currentTime newTime)
                 (tset :timeLeft newLeft)
                 (tset :expired false)
                 (tset :value newVal)
                 ))))
     )

   (fn remove [self] (tset self :discarded true))
   (fn pause [self] (tset self :paused true))
   (fn start [self] (tset self :paused false))

   (fn new [duration startValue endValue ease]
     (let [easingFunction (or ease easing.linear)
           startValue (or startValue 0)
           endValue (or endValue 0)
           value startValue
           discardOnCompletion true
           reverses false
           expired false
           paused false
           timeLeft duration
           currentTime 0
           timer { : value : startValue : endValue : duration : isValid
                   : discardOnCompletion : currentTime : reverses
                   : timeLeft : expired : paused
                   : easingFunction
                   : reset  : remove
                   }]
       (table.insert timer-state.all-timers timer)
       timer))

   (fn updateTimers []
     ;; tODO - timer not saving time?
     (let [dt (math.floor (* (love.timer.getDelta) 1000))]
       (each [i timer (ipairs timer-state.all-timers)]
         (advance timer dt))
       (tset timer-state :all-timers
             (icollect [i timer (ipairs timer-state.all-timers)]
               (if timer.discarded nil timer)))
       )
     )))
