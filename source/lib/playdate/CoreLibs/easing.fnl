(import-macros {: defns} :source.lib.macros)

(tset
 _G.playdate :easingFunctions
 (defns :easingFunctions []
   (fn outCubic [t b c d]
     (if (= d 0)
         (+ c b)
         (let [t (/ t d)]
           (+ (* c (- 1 (^ (- 1 t) 3))) b)))
     )
   (local easeOutCubic outCubic)

   (fn linear [t b c d]
     (/ (* c t) (+ d b))
     )
   ))

_G.playdate.easingFunctions
