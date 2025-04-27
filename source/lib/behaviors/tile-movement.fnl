(import-macros {: inspect : defns : pd/import : div} :source.lib.macros)

(defns :source.lib.behaviors.tile-movement
  [gfx playdate.graphics]

  (fn tile-movement-react! [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h }
                             &as self}
                            speed]
    (let [curr-tile-x (/ self.x tile-w)
          curr-tile-y (/ self.y tile-h)
          [norm-x norm-y] (self:move-normals)
          dx (* speed norm-x)
          dy (* speed norm-y)
          dx (if (> dx 0)
                 (math.min dx state.move-x)
                 (< dx 0)
                 (math.max dx state.move-x)
                 dx)
          dy (if (> dy 0)
                 (math.min dy state.move-y)
                 (< dy 0)
                 (math.max dy state.move-y)
                 dy)
          ]
      (tset self.state :tile-x state.tile-x)
      (tset self.state :tile-y state.tile-y)
      (tset self.state :facing state.facing)
      (tset state :move-x (- state.move-x dx))
      (tset state :move-y (- state.move-y dy))
      (if (and (= state.move-x 0) (= state.move-y 0))
          (do (self:->stop! dx dy)
              ;; TODO - round to nearest tile
              (values dx dy))
          (values dx dy))))

  (fn move-normals [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h }
                     :state { : speed : tile-x : tile-y} &as self}]
    (if
     (> 0 state.move-x)
     [-1 0]
     (> state.move-x 0)
     [1 0]
     (> 0 state.move-y)
     [0 -1]
     (> state.move-y 0)
     [0 1]
     ;; else
     [0 0]))

  (fn ->left! [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h } &as self}]
    (tset state :move-x (- (or state.move-x 0) tile-w))
    (tset state :tile-x (- state.tile-x 1))
    (tset state :facing :left)
    (tset state :moving :left))

  (fn ->right! [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h } &as self}]
    (tset state :move-x (+ (or state.move-x) tile-w))
    (tset state :tile-x (+ state.tile-x 1))
    (tset state :facing :right)
    (tset state :moving :right))

  (fn ->up! [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h } &as self}]
    (tset state :move-y (- (or state.move-y 0) tile-h))
    (tset state :tile-y (- state.tile-y 1))
    (tset state :facing :up)
    (tset state :moving :up))

  (fn ->down! [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h } &as self}]
    (tset state :move-y (+ (or state.move-y 0) tile-h))
    (tset state :tile-y (+ state.tile-y 1))
    (tset state :facing :down)
    (tset state :moving :down))

  (fn ->face! [{:tile-movement-state state &as self} face]
    (tset state :facing face)
    )

  (fn ->stop! [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h } &as self} dx dy]
    ;; (tset state :move-x (% (+ self.x (or dx 0)) tile-w))
    ;; (tset state :move-y (% (+ self.y (or dy 0)) tile-h))
    (let [target-x-tile (math.floor (+ (/ (+ self.x (or dx 0)) tile-w) 0.5))
          diff-x (- (* target-x-tile tile-w) self.x)
          target-y-tile (math.floor (+ (/ (+ self.y (or dy 0)) tile-h) 0.5))
          diff-y (- (* target-y-tile tile-h) self.y)]
      ;; (tset state :move-x diff-x)
      (tset state :tile-x target-x-tile)
      ;; (tset state :move-y diff-y)
      (tset state :tile-y target-y-tile)
      ;; TODO: This was supposed to correct tile misalignment - bounce back
      ;; but it also causes weirdness
      ;; (tset self :x (+ (* target-x-tile tile-w) (- (or dx 0))))
      ;; (tset self :y (+ (* target-y-tile tile-h) (- (or dy 0))))
      (tset state :moving nil)
      (values diff-x diff-y)))

  (fn add! [item opts]
    (tset item :tile-movement-opts opts)
    (tset item :tile-movement-state {:facing (or opts.default-facing :down) :moving nil
                                     :move-x 0 :move-y 0
                                     :tile-x (div item.x opts.tile-w)
                                     :tile-y (div item.y opts.tile-h)
                                     })
    (tset item :tile-movement-react! tile-movement-react!)
    (tset item :->left! ->left!)
    (tset item :->right! ->right!)
    (tset item :->up! ->up!)
    (tset item :->down! ->down!)
    (tset item :->stop! ->stop!)
    (tset item :->face! ->face!)
    (tset item :move-normals move-normals)
    item))
