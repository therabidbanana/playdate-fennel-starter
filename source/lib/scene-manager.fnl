(let []
  (fn add-scene! [$ name scene]
    (doto $ (tset :scenes name scene)))

  (fn tick! [$]
    )

  {: add-scene!
   : tick!
   :scenes {}
   })
