(let [pressed? playdate.buttonIsPressed
      gfx playdate.graphics]
  (fn react! [player]
    (let [dy (if (pressed? playdate.kButtonUp) (* -1 player.state.speed)
                 (pressed? playdate.kButtonDown) (* 1 player.state.speed)
                 0)
          dx (if (pressed? playdate.kButtonLeft)
                 (* -1 player.state.speed)
                 (pressed? playdate.kButtonRight)
                 (* 1 player.state.speed)
                 0)
          dx (if (and (>= (+ player.x player.width) 400) (> dx 0)) 0
                 (and (<= player.x 0) (< dx 0)) 0
                 dx)
          dy (if (and (>= (+ player.y player.height) 240) (> dy 0)) 0
                 (and (<= player.y 0) (< dy 0)) 0
                 dy)]
      (player:moveBy dx dy))
    player)

  (fn new! [x y]
    (let [image (playdate.graphics.imagetable.new :images/tiles)
          player (playdate.graphics.sprite.new (image:getImage 1 3))]
      (player:setBounds x y 16 16)
      (player:setCenter 1 1)
      (tset player :update react!)
      (tset player :state {:speed 2})
      player))

  {: new!})

