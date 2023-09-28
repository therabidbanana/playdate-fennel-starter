(fn inspect [val name]
  (let [inspected (or name (tostring val))]
    `(let [result# ,val]
       (if (= (type ,val) :table)
           (do
             (print (.. ,inspected " => "))
             (printTable ,val))
           (print (.. ,inspected " => " ,val)))
       result#)))

{: inspect}

