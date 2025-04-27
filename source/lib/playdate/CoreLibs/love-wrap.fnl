(import-macros {: defmodule : inspect : div} :source.lib.macros)

(if (not (?. _G :love-wrap))
    (tset _G :love-wrap {}))

(defmodule _G.love-wrap
  []

  (local state {:tx 0 :ty 0})

  (fn set-offset! [x y]
    (tset state :tx x)
    (tset state :ty y))

  (fn ->x [x] (+ state.tx x))
  (fn ->y [y] (+ state.ty y))

  (fn printf [text x y w]
    (love.graphics.printf text (->x x) (->y y) w))

  (fn rectangle [mode x y ...]
    (love.graphics.rectangle mode (->x x) (->y y) ...))

  (fn draw [drawable a b n]
    (if n
        (love.graphics.draw drawable a (->x b) (->y n))
        (love.graphics.draw drawable (->x a) (->y b))))
  )
