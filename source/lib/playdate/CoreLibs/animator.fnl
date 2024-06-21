(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :animator))
    (tset _G.playdate.graphics :animator {}))

(defmodule _G.playdate.graphics.animator
  [timer _G.playdate.timer]

  (fn currentValue [self]
    self.timer.value)

  (fn ended [self]
    self.timer.expired)

  (fn new [duration start end easing delayed]
    (let [timer (timer.new duration start end easing)
          __state {}
          item { : timer : __state
                 : currentValue : ended}]
      (setmetatable item {:__index (fn [tbl key]
                                     (if (= :paused key)
                                         tbl.timer.paused
                                         (. tbl.__state key)))
                          :__newindex (fn [tbl key val]
                                        (if (= :paused key)
                                            (tset tbl.timer :paused val)
                                            (tset tbl.__state key val)))})
      ))
 )
