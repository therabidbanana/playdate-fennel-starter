(import-macros {: inspect} :source.lib.macros)

(let [pressed? playdate.buttonIsPressed
      gfx playdate.graphics
      scene-manager (require :source.lib.scene-manager)]
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
      (if (playdate.buttonJustPressed playdate.kButtonB)
          (scene-manager:select! :menu)))
    self)

  (fn update [{:state {: dx : dy : visible} &as self}]
    (self:moveBy dx dy))

  (fn new! [x y]
    (let [image (playdate.graphics.imagetable.new :assets/images/tiles)
          player (playdate.graphics.sprite.new (image:getImage 1 3))]
      (player:setBounds x y 16 16)
      (player:setCenter 0 0)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :state {:speed 2 :dx 0 :dy 0 :visible true})
      player))

  {: new!})

