(import-macros {: inspect : defmodule } :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate.graphics :sprite))
    (tset _G.playdate.graphics :sprite {}))

(defmodule
 _G.playdate.graphics.sprite
 [(ok? bit) (pcall require :bit)
  bit       (if ok?
                bit
                {:band (fn bitand [num other]
                         (var found 0)
                         (var a num)
                         (var b other)
                         (for [i 1 32]
                           (if (= (% a 2) (% b 2) 1)
                               (set found (+ found (^ 2 (- i 1)))))
                           (set a (math.floor (/ a 2)))
                           (set b (math.floor (/ b 2)))
                           )
                         found)})
  ;; (require :bit)
   love-wrap (require :source.lib.playdate.love-wrap)
  ]

 (local sprite-state {:sprites []})
 (fn -contains? [b1 p2]
   (and (<= b1.x p2.x (+ b1.x b1.w))
        (<= b1.y p2.y (+ b1.y b1.h))
        ))
 (fn -collides? [b1 b2]
   (and (> (+ b1.x b1.w) b2.x)
        (< b1.x (+ b2.x b2.w))
        (> (+ b1.y b1.h) b2.y)
        (< b1.y (+ b2.y b2.h))
        ))
 (fn -inGroups? [collides-with groups]
   (> (bit.band groups collides-with) 0))

 (fn update []
   (each [i sprite (ipairs sprite-state.sprites)]
     (sprite:update))
   (each [i sprite (ipairs sprite-state.sprites)]
     (if (?. sprite :draw)
         (let []
           (playdate.graphics.pushContext)
           (if sprite.ignores-offset
               (do
                 (playdate.graphics.setDrawOffset sprite.x sprite.y)
                 (sprite:draw 0 0)
                 )
               (sprite:draw sprite.x sprite.y))
           (playdate.graphics.popContext)
           )))
   )

 (fn remove [self]
   (tset sprite-state :sprites
         (icollect [i spr (ipairs sprite-state.sprites)]
           (if (= spr self) nil spr))))

 (fn removeAll []
   (tset sprite-state :sprites [])
   )

 (fn getAllSprites []
   (?. sprite-state :sprites)
   )

 (fn overlappingSprites [self]
   (if self.collisionBox
       (icollect [i sprite (ipairs sprite-state.sprites)]
         (if (= sprite self) nil
             (and sprite.collisionBox
                  (-inGroups? self.collide-mask sprite.group-mask)
                  (-collides? self.collisionBox sprite.collisionBox))
             sprite))
       [])
   )


 (fn performOnAllSprites [func]
   (each [i sprite (ipairs sprite-state.sprites)]
     (func sprite)))

 ;; Instance methods
 (fn setBounds [self x y w h]
   (tset self :x x)
   (tset self :y y)
   (tset self :width w)
   (tset self :height h))

 (fn getBoundsRect [self]
   (_G.playdate.geometry.rect.new self.x self.y self.width self.height))

 (fn setCenter [self x y] "TODO")
 (fn setSize [self w h] (tset self :width w) (tset self :height h))
 (fn setIgnoresDrawOffset [self ignores-offset]
   (tset self :ignores-offset ignores-offset))
 (fn setImage [self image]
   (if (not= self.image image)
       (let [(w h) (image:getSize)]
         (tset self :width w)
         (tset self :height h)
         (tset self :image image)
         (self:markDirty))))
 (fn instance-update [self] self)

 (fn setVisible [self visible]
   (tset self :visible visible))

 (fn draw [self x y]
   (if
    (not self.visible) nil
    self.image (self.image:draw x y))
   ;; (love.graphics.drawq self.image self.x self.y)
   )

 (fn add [self]
   (table.insert sprite-state.sprites self)
   (table.sort sprite-state.sprites
               (fn [a b] (< a.z-index b.z-index)))
   )

 (fn setTilemap [self tilemap]
   (let [(w h) (tilemap:getPixelSize)]
     (tset self :width w)
     (tset self :height h)
     (tset self :image tilemap))
   )

 (fn addEmptyCollisionSprite [& rest]
   (let [sprite (_G.playdate.graphics.sprite.new)
         (x y w h)
         (case rest
           [{: w : h : x : y}] (values x y w h)
           [x y w h] (values x y w h)
           )]
     (doto sprite
       (: :setCenter 0 0)
       (: :setBounds x y w h)
       (: :setCollideRect 0 0 w h)
       (: :add))))

 (fn addWallSprites [tilemap]
   (let [tilerects (tilemap:getCollisionRects)]
     (icollect [i rect (ipairs tilerects)]
       (addEmptyCollisionSprite rect))))

 (fn querySpritesAtPoint [& rest]
   (let [point (case rest
                [{: x : y}]
                {: x : y}
                [x y]
                {: x : y})]
     (icollect [i spr (ipairs sprite-state.sprites)]
       (if (and spr.collisionBox
                (-contains? spr.collisionBox point))
           spr)
       )))

 (fn querySpritesInRect [& rest]
   (let [rect (case rest
                [{: x : y : w : h : width : height}]
                {: x : y : w : h}
                [x y w h]
                {: x : y : w : h})]
     (icollect [i spr (ipairs sprite-state.sprites)]
       (if (and spr.collisionBox
                (-collides? rect spr.collisionBox))
           spr)
       )))

 (fn -updateCollisionBox [self]
   (if self.collideRect
       (let [{: x : y} self
             {:x cx :y cy : h : w} self.collideRect]
         (tset self :collisionBox {:x (+ x cx) :y (+ y cy) : h : w})))
   )

 (fn setCollideRect [self x y w h]
   (tset self :collideRect {: x : y : w : h})
   (-updateCollisionBox self)
   )

 (fn setGroups [self list]
   (var mask 0)
   (each [i v (ipairs list)]
     (set mask (+ mask (^ 2 v))))
   (tset self :group-mask mask)
   (tset self :groups list))

 (fn setCollidesWithGroups [self list]
   (var mask 0)
   (each [i v (ipairs list)]
     (set mask (+ mask (^ 2 v))))
   (tset self :collide-mask mask)
   (tset self :collideGroups list)
   )

 (local inf math.huge)
 (local -inf (- math.huge))

 ;; https://www.gamedev.net/tutorials/programming/general-and-gameplay-programming/swept-aabb-collision-detection-and-response-r3084/
 ;; https://gist.github.com/tesselode/e1bcf22f2c47baaedcfc472e78cac55e
 (fn -sweptaabb [a b dx dy]
   (if (= (+ dx dy) 0)
       ;; Not moving is not colliding
       (values 0 0 1)
       ;; No move on X and not already collide on x axis - skip
       (and (= dx 0) (or (<= (+ a.x a.w) b.x)
                         (<= (+ b.x b.w) a.x)))
       (values 0 0 1)
       ;; No move on Y and not already collide on y axis - skip
       (and (= dy 0) (or (<= (+ a.y a.h) b.y)
                         (<= (+ b.y b.h) a.y)))
       (values 0 0 1)
       (let [;; Distance to entry/exit inverse
             ax2 (+ a.x a.w)
             bx2 (+ b.x b.w)
             ay2 (+ a.y a.h)
             by2 (+ b.y b.h)
             xinventry (if (> dx 0)
                           (- b.x ax2)
                           (- bx2 a.x))
             xinvexit (if (> dx 0)
                          (- bx2 a.x)
                          (- b.x ax2))
             yinventry (if (> dy 0)
                           (- b.y ay2)
                           (- by2 a.y))
             yinvexit (if (> dy 0)
                          (- by2 a.y)
                          (- b.y ay2))
             ;; Time to enter/exit based on distance
             xenter (if (= dx 0) -inf (/ xinventry dx))
             xexit (if (= dx 0) inf (/ xinvexit dx))
             yenter (if (= dy 0) -inf (/ yinventry dy))
             yexit (if (= dy 0) inf (/ yinvexit dy))
             ;; Determine entry exit times scaled 0 (curr) to 1 (full move) (infs should be ignored)
             entryTime (math.max xenter yenter)
             exitTime (math.min xexit yexit)
             missed? (or (> entryTime exitTime)
                         ;; (and (< xenter 0) (< yenter 0))
                         (and (> xenter yexit) (> yenter xexit))
                         (> xenter 1) (> yenter 1))]
         ;; (inspect {: a : b : dx : dy : xenter : yenter : entryTime : exitTime : missed? : yexit : xexit})
         (if missed?
             (values 0 0 1)

             (or (< xenter yenter) (= yenter -inf))
             (do
               (if (< xinventry 0)
                  (values 1 0 entryTime)
                  (values -1 0 entryTime)))

             (if (< yinventry 0)
                 (values 0 1 entryTime)
                 (values 0 -1 entryTime))
             )
         ))
   )

 (fn moveTo [self x y]
   (tset self :x x)
   (tset self :y y)
   (-updateCollisionBox self))

 (fn moveWithCollisions [self x y]
   (let [(new-x new-y collisions count) (self:checkCollisions x y)]
     ;; (if first-hit (inspect first-hit))
     (moveTo self new-x new-y)
     (values new-x new-y collisions count)
     ))

 (fn checkCollisions [self x y]
   (let [box1 self.collisionBox
         dx (- x self.x)
         dy (- y self.y)
         minx (math.min box1.x (+ box1.x dx))
         miny (math.min box1.y (+ box1.y dy))
         maxx (math.max box1.x (+ box1.x dx))
         maxy (math.max box1.y (+ box1.y dy))
         moveBox {:x minx
                  :y miny
                  :w (+ (- maxx minx) box1.w)
                  :h (+ (- maxy miny) box1.h)}

         possible-collisions
         sprite-state.sprites

         collisions
         (icollect [i spr (ipairs sprite-state.sprites)]
           ;; TODO: Add broad phase check (simpler overlap aabb with bigger box)
           (if (= spr self) nil
               ;; Faster aabb
               (and spr.collisionBox
                    (-inGroups? self.collide-mask spr.group-mask)
                    (-collides? moveBox spr.collisionBox))
               (let [(normx normy collidedt) (-sweptaabb box1 spr.collisionBox dx dy)]
                 ;; TODO - response slide/bounce & ordering multiple?
                 (if (< collidedt 1)
                     {:sprite self :other spr
                      :spriteRect self.collisionBox :otherRect spr.collisionBox
                      :ti collidedt
                      :move {:x (+ (* collidedt dx))
                             :y (+ (* collidedt dy))}
                      :normal {:x normx :y normy}
                      :type (if (?. self :collisionResponse)
                                (if (= (type self.collisionResponse) :string)
                                    self.collisionResponse
                                    (self:collisionResponse spr))
                                :freeze)})
                 ))
           )
         count (length collisions)
         _ (table.sort collisions (fn [a b] (< a.ti b.ti)))
         actual-collides (icollect [i v (ipairs collisions)] (if (not= v.type :overlap) v))
         first-hit (?. actual-collides 1)
         new-x (if first-hit
                   (+ self.x first-hit.move.x)
                   x)
         new-y (if first-hit
                   (+ self.y first-hit.move.y)
                   y)
         ]
     ;; (if first-hit (inspect first-hit))
     (values new-x new-y collisions count)
     )
   )

 (fn markDirty [self]
   (tset self :dirty true))

 (fn moveBy [self dx dy]
   (tset self :x (+ self.x dx))
   (tset self :y (+ self.y dy))
   (-updateCollisionBox self))

 (fn setZIndex [self z-index] (tset self :z-index z-index))
 (fn new []
   (let [x -800
         y -800
         z-index 0
         width 1
         height 1
         ignores-offset false
         visible true
         dirty true
         sprite { : x : y : width : height : z-index : groups
                  : ignores-offset
                  : visible : dirty
                  :update instance-update}]
     (setmetatable sprite {:__index _G.playdate.graphics.sprite})
     sprite)
   )
 )
