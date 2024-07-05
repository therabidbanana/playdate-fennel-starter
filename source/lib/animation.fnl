(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(pd/import :CoreLibs/graphics)
(pd/import :CoreLibs/animation)

(defns :source.lib.animation
  [gfx playdate.graphics]

  (fn transition! [{: current-state : current-anim &as self} new-state opts]
    (let [{:if if-state} (or opts {})
          new-anim (. self.animations new-state)]
      (if (and (not= current-state new-state) (= current-state (or if-state current-state)))
          (do
            (if current-anim
                (doto current-anim
                  (tset :frame 1)
                  (tset :paused true)))
            (doto self
              (tset :current-state new-state)
              (tset :current-anim new-anim)
              (tset :current-anim :paused false))))
      self))

  (fn draw [{: current-anim &as self} x y]
    (if (current-anim:isValid)
        (current-anim:draw x y)
        ;; Else move to next frame and draw
        (do
          (self:transition! current-anim.transition-to)
          (self.current-anim:draw x y))
        )
    )

  (fn getImage [{: current-anim &as self}]
    (if (current-anim:isValid) (current-anim:image)
        ;; Else move to next frame and draw
        (do
          (self:transition! current-anim.transition-to)
          (self.current-anim:image))
        )
    )

  (fn new [{: image : delay : states : current-state }]
    (let [base-delay (or delay 150)
          current-state (or current-state (. states 1 :state))
          animations (collect [_ {: state : delay : start : end : transition-to } (ipairs states)]
                       (let [anim (gfx.animation.loop.new (or delay base-delay) image)]
                         (doto anim
                           (tset :startFrame start)
                           (tset :endFrame end)
                           (tset :transition-to transition-to)
                           (tset :paused true)
                           (tset :shouldLoop (if transition-to false true)))
                         (values state anim)))]
      (: {: transition! : draw : animations : getImage} :transition! current-state)))
  )
