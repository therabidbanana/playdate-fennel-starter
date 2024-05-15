(import-macros {: inspect : defns} :source.lib.macros)

(defns :player
  [pressed? playdate.buttonIsPressed
   gfx playdate.graphics
   $ui (require :source.lib.ui)
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
                 dy)
          [facing-x facing-y] (case state.facing
                                :left [(- x 8) (+ y (// height 2))]
                                :right [(+ 40 x) (+ y (// height 2))]
                                :up [(+ x (// width 2)) (- y 8)]
                                _ [(+ x (// width 2)) (+ 8 height y)]) ;; 40 for height / width of sprite + 8
          [facing-sprite & _] (gfx.sprite.querySpritesAtPoint facing-x facing-y)
          ]
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :facing (if (> 0 dx) :left
                                    (< 0 dx) :right
                                    (> 0 dy) :up
                                    (< 0 dy) :down
                                    (or state.facing :down)))

      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))

      (if (playdate.buttonJustPressed playdate.kButtonB)
          (scene-manager:select! :menu))
      (if (and (playdate.buttonJustPressed playdate.kButtonA)
               facing-sprite)
          ($ui:open-textbox! {:text (gfx.getLocalizedText "textbox.test2")}))
      )
    self)

  (fn update [{:state {: animation : dx : dy : walking?} &as self}]
    (let [target-x (+ dx self.x)
          target-y (+ dy self.y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)]
      (if walking?
         (animation:transition! :walking)
         (animation:transition! :standing {:if :walking})))
    (self:markDirty)
    )

  (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
    (animation:draw x y))

  (fn collisionResponse [self other]
    (other:collisionResponse))

  (fn new! [x y]
    (let [image (gfx.imagetable.new :assets/images/pineapple-walk)
          animation (anim.new {: image :states [{:state :standing :start 1 :end 1 :delay 2300 :transition-to :blinking}
                                                {:state :blinking :start 2 :end 3 :delay 300 :transition-to :pace}
                                                {:state :pace :start 4 :end 5 :delay 500 :transition-to :standing}
                                                {:state :walking :start 4 :end 5}]})
          player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 32 32)
      (player:setCollideRect 6 1 18 30)
      (player:setGroups [1])
      (player:setCollidesWithGroups [3 4])
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :state {: animation :speed 2 :dx 0 :dy 0 :visible true})
      player)))

