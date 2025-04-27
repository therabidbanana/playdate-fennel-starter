(fn inspect [val name]
  (let [inspected (or name (tostring val))]
    (if _G.LOVE
        `(let [result# ,val]
           (if (= (type ,val) :table)
               (do
                 (print (.. ,inspected " => "))
                 (printTable ,val)
                 )
               (print (.. ,inspected " => " ,val)))
           result#)
        `(let [result# ,val]
           (if (= (type ,val) :table)
               (do
                 (print (.. ,inspected " => "))
                 (printTable ,val))
               (print (.. ,inspected " => " (if (= nil ,val) "nil" ,val))))
           result#))))

(fn div [a b]
  (if _G.LOVE
      `(math.floor (/ ,a ,b))
      `(// ,a ,b)))

;; PD version from https://github.com/bakpakin/Fennel/issues/421#issuecomment-1103070078
(fn pd/import [lib]
  (if _G.LOVE
      `(require ,(.. "source.lib.playdate." (lib:gsub "%/" ".")))
      `(lua ,(.. "import \"" lib "\""))))


(fn defns [ns-name bindings & forms]
  (let [names (icollect [_ [t name & def] (ipairs forms)]
                (if (= t (sym :local)) name
                    (= t (sym :var)) name
                    (= t (sym :fn)) name))
        map (collect [_ name (ipairs names)]
              (values (tostring name) name))
        let-block `(let ,bindings ,(unpack forms))]
    (table.insert let-block map)
    let-block))

(fn clamp [min x max]
  `(math.max (math.min ,x ,max) ,min))

(fn round [val]
  `(math.floor (+ 0.5 ,val)))

(fn defmodule [module bindings & forms]
  (let [names (icollect [_ [t name & def] (ipairs forms)]
                (if (= t (sym :local)) name
                    (= t (sym :var)) name
                    (= t (sym :fn)) name))
        map (collect [_ name (ipairs names)]
              (values (tostring name) name))
        let-block `(let ,bindings ,(unpack forms))
        each-block `(each [k# v# (pairs ,map)] (tset ,module k# v#))
        ]
    (table.insert let-block each-block)
    (table.insert let-block module)
    let-block))

(fn love-hooks [bindings ...]
  (let [code-load (defns :game bindings ...)]
    `(do
       (fn _G.printTable [tbl#]
         (fn tostr# [val#]
           (if (= val# nil)
               (.. "nil")
               (= (type val#) :table)
               (.. "{"
                   (table.concat (icollect [i# v# (pairs val#)]
                                   (.. i# " = " (or (tostr# v#) "nil"))) "\n")
                   "}")
               (= (type val#) :function)
               "(fn [])"
               (= (type val#) :boolean)
               (if val# "true" "false")
               (= (type val#) :userdata)
               "(love internal)"
               val#
               ))
         (print (tostr# tbl#))
         )
       (let [game# ,code-load
             fps# (/ 1 30)]
         (tset love :load (fn []
                            (tset love :next-time (love.timer.getTime))
                            (tset love :fps-dt fps#)
                            (playdate.love-load)
                            (game#.load-hook)
                            ))
         (tset love :update (fn []
                              (tset love :next-time (+ love.next-time love.fps-dt))
                              (game#.update-hook)
                              (playdate.love-update)))
         (tset love :draw (fn []
                            (let [cur-time# (love.timer.getTime)]
                              (playdate.love-draw-start)
                              (game#.draw-hook)
                              (when (?. game# :debug-draw)
                                (let [shader# (love.graphics.getShader)]
                                  (shader#:send "debugDraw" true)
                                  (game#.debug-draw)
                                  (shader#:send "debugDraw" false)
                                  )
                                )
                              (playdate.love-draw-end)
                              (if (< love.next-time cur-time#)
                                  (tset love :next-time cur-time#)
                                  (love.timer.sleep (- love.next-time cur-time#))
                                  )
                              )
                            ))))))

(fn playdate-hooks [bindings ...]
  (let [code-load (defns :game bindings ...)]
    `(let [game# ,code-load]
       (game#.load-hook)
       (tset playdate :update (fn [] (game#.update-hook) (game#.draw-hook)))
       (if (?. game# :debug-draw)
           (tset playdate :debugDraw (fn [] (game#.debug-draw))))
       )))

(fn pd/load [bindings ...]
  (if _G.LOVE
      (love-hooks bindings ...)
      (playdate-hooks bindings ...)
      ))

(fn love/patch []
  (if _G.LOVE
      `(lua "playdate = {}; LOVE = true")))

(fn require/patch []
  (if _G.LOVE
      `(lua "-- LOVE compiled from fennel")
      `(lua "
package = {loaded = {}, preload = {}}
function require(name)
  if not package.loaded[name] then
    local _2_
    _2_ = package.preload[name]
    package.loaded[name] = _2_()
  end
  local t_5_ = package.loaded
  if (nil ~= t_5_) then
    t_5_ = (t_5_)[name]
  end
  return t_5_
end
")
      ))

{: inspect : pd/import : pd/load : love/patch : require/patch
 : defns : defmodule
 : div : clamp : round  }

