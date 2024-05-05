(fn inspect [val name]
  (let [inspected (or name (tostring val))]
    `(let [result# ,val]
       (if (= (type ,val) :table)
           (do
             (print (.. ,inspected " => "))
             (printTable ,val))
           (print (.. ,inspected " => " ,val)))
       result#)))


;; https://github.com/bakpakin/Fennel/issues/421#issuecomment-1103070078
(fn pd/import [lib]
  `(lua ,(.. "import \"" lib "\"")))

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

{: inspect : pd/import : defns : clamp : round }

