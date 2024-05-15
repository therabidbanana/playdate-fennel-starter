(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(defns :source.lib.behaviors.tile-movement
  [gfx playdate.graphics]

  (fn tile-movement-react! [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h }
                             &as self}
                            speed]
    (let [tile-x (/ self.x tile-w)
          tile-y (/ self.y tile-h)
          [norm-x norm-y] (self:move-normals)
          dx (* speed norm-x)
          dy (* speed norm-y)
          ]
      (tset self.state :tile-x tile-x)
      (tset self.state :tile-y tile-y)
      (tset state :move-x (- state.move-x dx))
      (tset state :move-y (- state.move-y dy))
      (if (and (= state.move-x 0) (= state.move-y 0))
          (self:->stop! dx dy)
          )
      (values dx dy)))

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
    (tset state :move-x (- 0 tile-w))
    (tset state :move-y 0)
    (tset state :facing :left)
    (tset state :moving :left))

  (fn ->right! [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h } &as self}]
    (tset state :move-x tile-w)
    (tset state :move-y 0)
    (tset state :facing :right)
    (tset state :moving :right))

  (fn ->up! [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h } &as self}]
    (tset state :move-x 0)
    (tset state :move-y (- 0 tile-h))
    (tset state :facing :up)
    (tset state :moving :up))

  (fn ->down! [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h } &as self}]
    (tset state :move-x 0)
    (tset state :move-y tile-h)
    (tset state :facing :down)
    (tset state :moving :down))

  (fn ->stop! [{:tile-movement-state state :tile-movement-opts { : tile-w : tile-h } &as self} dx dy]
    (tset state :move-x (% (+ self.x (or dx 0)) tile-w))
    (tset state :move-y (% (+ self.y (or dy 0)) tile-h))
    (tset state :moving nil))

  (fn add! [item opts]
    (tset item :tile-movement-opts opts)
    (tset item :tile-movement-state {:facing (or opts.default-facing :down) :moving nil
                                     :move-x 0 :move-y 0
                                     })
    (tset item :tile-movement-react! tile-movement-react!)
    (tset item :->left! ->left!)
    (tset item :->right! ->right!)
    (tset item :->up! ->up!)
    (tset item :->down! ->down!)
    (tset item :->stop! ->stop!)
    (tset item :move-normals move-normals)
    item))
