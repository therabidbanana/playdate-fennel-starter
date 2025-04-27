(import-macros {: defmodule : inspect} :source.lib.macros)

(if (not (?. _G.playdate :pathfinder))
    (tset _G.playdate :pathfinder {}))

(if (not (?. _G.playdate :pathfinder :graph))
    (tset _G.playdate :pathfinder :graph {}))

(if (not (?. _G.playdate :pathfinder :node))
    (tset _G.playdate :pathfinder :node {}))


(defmodule
  _G.playdate.pathfinder
  []

  (local
   node
   (defmodule
     _G.playdate.pathfinder.node
     []

     (fn connectedNodes [self]
       (icollect [id w (pairs self.conns)]
         (self.graph:nodeWithID id)
         ))

     (fn addConnection [self neighbor weight recip?]
       (tset self.conns neighbor.id weight)
       (if recip? (neighbor:addConnection self weight))
       )

     (fn addConnections [self neighbors weights recip?]
       (each [i node (ipairs neighbors)]
         (let [weight (. weights i)]
           (tset self.conns node.id weight)
           (if recip? (node:addConnection self weight)))))

     (fn removeAllConnections [self recip?]
       (if recip?
           (each [neighborid _ (pairs self.conns)]
             (let [neighbor (self.graph:nodeWithID neighborid)]
               (neighbor:removeConnection self))))
       (tset self :conns {}))

     (fn removeConnection [self node recip?]
       (tset self.conns node.id nil)
       (if recip? (node:removeConnection self)))

     (fn new [graph id x y]
       (let [node {: id : x : y :conns {} : graph}]
         (setmetatable node {:__index _G.playdate.pathfinder.node})
         node))
     ))
  ;; end node

  (local
   graph
   (defmodule
     _G.playdate.pathfinder.graph
     []
     (local straight 10)
     (local diagonal 14)

     (fn -taxicab [{:x x1 :y y1} {:x x2 :y y2}]
       (* (+ (math.abs (- x1 x2))
             (math.abs (- y1 y2)))
          straight))

     (fn findPath [self curr goal heuristic]
       (let [heuristic (or heuristic -taxicab)
             distances {}
             frontier [{:weight (heuristic curr goal)
                        :actual 0
                        :from   nil
                        :node   curr}]]
         (var exit nil)
         (while (and (> (length frontier) 0) (= nil exit))
           (let [next-item (table.remove frontier 1)]
             (if (= next-item.node goal)
                 (set exit next-item)
                 (each [nodeid weight (pairs next-item.node.conns)]
                   (let [actual (+ weight next-item.actual)
                         step (self:nodeWithID nodeid)]
                     (if (and step
                              (< actual (or (?. distances nodeid) math.huge)))
                         (do
                           (tset distances nodeid actual)
                           (table.insert frontier {:weight (+ actual
                                                              (heuristic step goal))
                                                   : actual
                                                   :from next-item
                                                   :node step}))
                         ))
                   ))
             (table.sort frontier (fn [a b] (< a.weight b.weight)))
             ))
         (if exit
             (let [path []]
               (while exit
                 (table.insert path 1 exit.node)
                 (set exit exit.from))
               ;; (inspect {:num (length path)
               ;;           :path (icollect [i p (ipairs path)] p.id)
               ;;           :source curr})
               path))
         ))

     (fn -xyNodeId [x y w] (+ x (* (- y 1) w)))
     (fn nodeWithID [self id]
       (?. self.nodes id))
     (fn nodeWithXY [self x y]
       (?. (icollect [_ n (ipairs self.nodes)]
             (if (and (= n.x x) (= n.y y)) n)) 1))
     (fn allNodes [self] (icollect [x n (pairs self.nodes)] n))
     (fn addNewNode [self id x y]
       (let [node (node.new self id x y)]
         (tset self.nodes id node)))

     (fn addConnectionToNodeWithID [self from to weight recip]
       (let [source (self:nodeWithID from)
             dest (self:nodeWithID to)]
         (if (and dest source) (tset source :conns to weight))
         (if (and recip dest source) (tset dest :conns from weight))
         ))

     (fn addConnections [self connections]
       (each [source conns (pairs connections)]
         (for [i 1 (length conns) 2]
           (self:addConnectionToNodeWithID source (?. conns i) (?. conns (+ i 1))))))

     (fn -adjacentNodeIds [gridx gridy gridw gridh diagonals]
       (let [ids []]
         ;; to the topright
         (if (and diagonals (> gridw gridx) (> gridy 1))
             (do
               (table.insert ids (-xyNodeId (+ gridx 1) (- gridy 1) gridw))
               (table.insert ids diagonal))
             )
         ;; to the topleft
         (if (and diagonals (> gridx 1) (> gridy 1))
             (do
               (table.insert ids (-xyNodeId (- gridx 1) (- gridy 1) gridw))
               (table.insert ids diagonal)))
         ;; to the bottomright
         (if (and diagonals (> gridw gridx) (> gridh gridy))
             (do
               (table.insert ids (-xyNodeId (+ gridx 1) (+ gridy 1) gridw))
               (table.insert ids diagonal))
             )
         ;; to the bottomleft
         (if (and diagonals (> gridx 1) (> gridh gridy))
             (do
               (table.insert ids (-xyNodeId (- gridx 1) (+ gridy 1) gridw))
               (table.insert ids diagonal)))
         ;; to the right
         (if (> gridw gridx)
             (do
               (table.insert ids (-xyNodeId (+ gridx 1) gridy gridw))
               (table.insert ids straight))
             )
         ;; to the left
         (if (> gridx 1)
             (do
               (table.insert ids (-xyNodeId (- gridx 1) gridy gridw))
               (table.insert ids straight))
             )
         ;; to the top
         (if (> gridy 1)
             (do
               (table.insert ids (-xyNodeId gridx (- gridy 1) gridw))
               (table.insert ids straight))
             )
         ;; to the bottom
         (if (> gridh gridy)
             (do
               (table.insert ids (-xyNodeId gridx (+ gridy 1) gridw))
               (table.insert ids straight)))
         ids)
       )

     (fn new2DGrid [width height diagonals nodelist]
       (let [nodes {}
             connections {}
             graph {: nodes :w width :h height : connections}
             hasNode (if nodelist
                         (fn [id] (?. nodelist id))
                         (fn [id] 1))
             ]
         ;; TODO: improve 2d logic - unclear if the connection setup is correctly
         ;; accounting for reciprical connections
         ;;
         ;; TODO: set up XY lookup table
         (for [y 1 height]
           (for [x 1 width]
             (let [id (-xyNodeId x y width)]
               (if (= 1 (hasNode id))
                   (tset nodes id (node.new graph id x y))))))
         (for [y 1 height]
           (for [x 1 width]
             (let [nodeid (-xyNodeId x y width)]
               (if (?. nodes nodeid)
                   (tset connections nodeid (-adjacentNodeIds x y width height diagonals))))
             ))
         (graph:addConnections connections)
         (setmetatable graph {:__index _G.playdate.pathfinder.graph})
         graph)
       )

     ;; TODO: fix node creation to handle x y coords passed in
     (fn new [len]
       (let [nodes {}
             connections {}
             graph {: nodes : connections}]
         (setmetatable graph {:__index _G.playdate.pathfinder.graph})
         (if len
             (for [x 1 len]
               (graph:addNewNode x)))
         graph)
       )
     )
   )
  ;; end graph
  )
