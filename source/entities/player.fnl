(fn react! [player]
  (if (playdate.buttonIsPressed playdate.kButtonUp) (player:moveBy 0 -1))
  (if (playdate.buttonIsPressed playdate.kButtonLeft) (player:moveBy -1 0))
  (if (playdate.buttonIsPressed playdate.kButtonDown) (player:moveBy 0 1))
  (if (playdate.buttonIsPressed playdate.kButtonRight) (player:moveBy 1 0))
  player)

(fn new! [x y]
  (let [image  (playdate.graphics.tilemap.new)
        _ (image:setImageTable (playdate.graphics.imagetable.new "images/player"))
        _ (image:setTiles [2 1 2] 8)
        player (playdate.graphics.sprite.new image)]
     (player:setBounds x y 8 8)
     (tset player :update react!)
     player
  ))

{: new!}