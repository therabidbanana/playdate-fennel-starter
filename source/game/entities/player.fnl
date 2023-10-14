(import-macros {: inspect : defns} :source.lib.macros)

(defns :player
  [pressed? playdate.buttonIsPressed
   gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   anim (require :source.lib.animation)]

  (fn react! [{: state : height : x : y : width &as self}]
    (let [dy (if (pressed? playdate.kButtonUp) (* -1 state.speed)
                 (pressed? playdate.kButtonDown) (* 1 state.speed)
                 0)
          dx (if (pressed? playdate.kButtonLeft) (* -1 state.speed)
                 (pressed? playdate.kButtonRight) (* 1 state.speed)
                 0)
          dx (if (and (>= (+ x width) 400) (> dx 0)) 0
                 (and (<= x 0) (< dx 0)) 0
                 dx)
          dy (if (and (>= (+ y height) 240) (> dy 0)) 0
                 (and (<= y 0) (< dy 0)) 0
                 dy)]
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))
      (if (playdate.buttonJustPressed playdate.kButtonB)
          (scene-manager:select! :menu)))
    self)

  (fn update [{:state {: animation : dx : dy : walking?} &as self}]
    (if walking?
        (animation:transition! :walking)
        (animation:transition! :standing {:if :walking}))
    (self:markDirty)
    (self:moveBy dx dy))

  (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
    (animation:draw x y))

  (fn new! [x y]
    (let [image (gfx.imagetable.new :assets/images/pineapple-walk)
          animation (anim.new {: image :states [{:state :standing :start 1 :end 1 :delay 2300 :transition-to :blinking}
                                                {:state :blinking :start 2 :end 3 :delay 300 :transition-to :pace}
                                                {:state :pace :start 4 :end 5 :delay 500 :transition-to :standing}
                                                {:state :walking :start 4 :end 5}]})
          player (gfx.sprite.new)]
      (player:setBounds x y 32 32)
      (player:setCenter 0 0)
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :state {: animation :speed 2 :dx 0 :dy 0 :visible true})
      player)))

