(import-macros {: div : inspect : defns : pd/import} :source.lib.macros)

(defns :source.lib.graph
  [gfx     playdate.graphics
   pdgraph playdate.pathfinder.graph]

  ;; Returns diagonals or non-diagonals, not both
  (fn -grid-neighbors-for [g x y diagonal?]
    (let [nodes []
          find g.nodeWithXY
          tl (find g (- x 1) (- y 1)) tm (find g x (- y 1))   tr (find g (+ x 1) (- y 1))
          ml (find g (- x 1) y)       mm (find g x y)         mr (find g (+ x 1) y)
          bl (find g (- x 1) (+ y 1)) bm (find g x (+ y 1))   br (find g (+ x 1) (+ y 1))]
      (when (not diagonal?)
        (if tm (table.insert nodes tm))
        (if bm (table.insert nodes bm))
        (if ml (table.insert nodes ml))
        (if mr (table.insert nodes mr)))
      (when diagonal?
        (if tl (table.insert nodes tl))
        (if bl (table.insert nodes bl))
        (if tr (table.insert nodes tr))
        (if br (table.insert nodes br))
        )
      nodes))

  (fn draw [{: tile-size &as self}]
    (each [_ node (ipairs (self._graph:allNodes))]
      (let [x (* tile-size node.x)
            y (* tile-size node.y)
            mid-x (+ x (div tile-size 2))
            mid-y (+ y (div tile-size 2))
            rect (playdate.geometry.rect.new x y tile-size tile-size)
            neighbors (node:connectedNodes)]
        (gfx.drawCircleInRect (rect:insetBy 6 6))
        (each [_ neighbor (ipairs neighbors)]
          (gfx.drawLine mid-x mid-y
                        (* tile-size (+ neighbor.x 0.5)) (* tile-size (+ neighbor.y 0.5))
                        ))
        )
      )
    )

  (fn remove-walls [{: tile-size &as self} walls]
    (each [_ wall (ipairs walls)]
      (let [wall-bounds (wall:getBoundsRect)]
        (each [_ node (ipairs (self._graph:allNodes))]
          ;; + 1 is a hack to avoid boundary points
          (if (wall-bounds:containsPoint (+ (* tile-size node.x) 1) (+ (* tile-size node.y) 1))
              (node:removeAllConnections true))
         )))
    self
    )

  (fn at-tile [self tile-x tile-y]
    (self._graph:nodeWithXY tile-x tile-y))

  (fn at-point [self point-x point-y]
    (let [x (div point-x self.tile-size)
          y (div point-y self.tile-size)]
      (self:at-tile x y)))

  (fn location-node [{: locations &as self} name]
    (let [node (?. locations name)]
      (if node (self:at-tile node.tile-x node.tile-y))))

  (fn next-step [self curr goal]
    (let [path (self._graph:findPath curr goal)
          next-one (?. path 2)]
      next-one))

  (fn new-tile-graph [tile-w tile-h {: diagonals : locations : tile-size}]
    (let [tile-list []
          _graph (pdgraph.new)
          tiles (for [h 0 (- tile-h 1)]
                  (for [w 0 (- tile-w 1)]
                    (_graph:addNewNode (+ (* tile-w h) w) w h) ;; x, y coords
                    ))
          ]
      (each [_ node (ipairs (_graph:allNodes))]
        (let [neighbors (-grid-neighbors-for _graph node.x node.y)
              weights   (icollect [_ _ (ipairs neighbors)] 10)]
          (node:addConnections neighbors weights true))
        )
      { : _graph : locations : tile-size
        : at-tile : at-point : location-node : next-step : draw
        : remove-walls
        }
      ))
  )
