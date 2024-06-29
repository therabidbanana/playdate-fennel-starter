(import-macros {: inspect : defns : div} :source.lib.macros)

(defns :npc
  [gfx playdate.graphics
   scene-manager (require :source.lib.scene-manager)
   tile (require :source.lib.behaviors.tile-movement)
   $ui (require :source.lib.ui)
   anim (require :source.lib.animation)]

  (fn react! [{: state : height : x : y : tile-w : tile-h : width &as self}]
    
    (let [(dx dy) (self:tile-movement-react! state.speed)]
      (if (and (= dx 0) (= dy 0))
          (case (math.random 0 100)
            1 (self:->left!)
            2 (self:->right!)
            3 (self:->up!)
            4 (self:->down!)
            _ nil))
      (tset self :state :dx dx)
      (tset self :state :dy dy)
      (tset self :state :walking? (not (and (= 0 dx) (= 0 dy))))
      )
    self)

  (fn update [{:state {: animation : dx : dy : walking?} &as self}]
    (let [target-x (+ dx self.x)
          target-y (+ dy self.y)
          (x y collisions count) (self:moveWithCollisions target-x target-y)]
      (if walking?
          (animation:transition! :walking)
          (animation:transition! :standing {:if :walking}))
      (tset self :state :dx 0)
      (tset self :state :dy 0)
      (if (> count 0) (self:->stop!))
      (self:markDirty))
    )

  (fn draw [{:state {: animation : dx : dy : visible : walking?} &as self} x y w h]
    (animation:draw x y))

  ;; (fn collisionResponse [self other]
  ;;   (other:collisionResponse))

  (fn new! [x y {: tile-h : tile-w}]
    (let [image (gfx.imagetable.new :assets/images/pineapple-walk)
          animation (anim.new {: image :states [{:state :standing :start 1 :end 1 :delay 2300 :transition-to :blinking}
                                                {:state :blinking :start 2 :end 3 :delay 300 :transition-to :pace}
                                                {:state :pace :start 4 :end 5 :delay 500 :transition-to :standing}
                                                {:state :walking :start 4 :end 5}]})
          player (gfx.sprite.new)]
      (player:setCenter 0 0)
      (player:setBounds x y 32 32)
      ;; (player:setCollideRect 6 1 18 30)
      (player:setCollideRect 0 0 32 32)
      (player:setGroups [3])
      (player:setCollidesWithGroups [1 4])
      (tset player :draw draw)
      (tset player :update update)
      (tset player :react! react!)
      (tset player :tile-h tile-h)
      (tset player :tile-w tile-w)
      (tset player :state {: animation :speed 2 :dx 0 :dy 0 :visible true
                           :tile-x (div x tile-w) :tile-y (div y tile-h)})
      (tile.add! player {: tile-h : tile-w})
      player)))

