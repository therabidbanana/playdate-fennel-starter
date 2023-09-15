(fn react! [player]
  (if (playdate.buttonIsPressed playdate.kButtonUp) (player:moveBy 0 (* -1 player.state.speed)))
  (if (playdate.buttonIsPressed playdate.kButtonLeft) (player:moveBy (* -1 player.state.speed) 0))
  (if (playdate.buttonIsPressed playdate.kButtonDown) (player:moveBy 0 (* 1 player.state.speed)))
  (if (playdate.buttonIsPressed playdate.kButtonRight) (player:moveBy (* 1 player.state.speed) 0))
  player)

(fn new! [x y]
  (let [
        image (playdate.graphics.imagetable.new "images/tiles")
        
        player (playdate.graphics.sprite.new (image:getImage 1 3))]
     (player:setBounds x y 16 16)
     (tset player :update react!)
     (tset player :state {:speed 2})
     player
  ))

{: new!}