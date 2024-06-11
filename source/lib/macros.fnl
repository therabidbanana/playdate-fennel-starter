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
               (print (.. ,inspected " => " ,val)))
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
                    (= t (sym :fn)) name))
        map (collect [_ name (ipairs names)]
              (values (tostring name) name))]
    `(let ,bindings
       ,forms
       ,map)))

(fn clamp [min x max]
  `(math.max (math.min ,x ,max) ,min))

(fn round [val]
  `(math.floor (+ 0.5 ,val)))

(fn defmodule [module bindings & forms]
  (let [names (icollect [_ [t name & def] (ipairs forms)]
                (if (= t (sym :local)) name
                    (= t (sym :fn)) name))
        map (collect [_ name (ipairs names)]
              (values (tostring name) name))]
    `(let ,bindings
       ,forms
       (each [k# v# (pairs ,map)]
         (tset ,module k# v#))
       ,module)))

(fn love-hooks [bindings ...]
  (let [code-load (defns :game bindings ...)]
    `(do
       (fn _G.printTable [tbl#]
         (fn tostr# [val#]
           (if (= (type val#) :table)
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
       (tset playdate :update (fn [] (game#.update-hook) (game#.draw-hook))))))

(fn pd/load [bindings ...]
  (if _G.LOVE
      (love-hooks bindings ...)
      (playdate-hooks bindings ...)
      ))

(fn love/patch []
  (if _G.LOVE
      `(lua "playdate = {}; LOVE = true")))

{: inspect : pd/import : pd/load : love/patch : defns
 : div : clamp : round : defmodule }

