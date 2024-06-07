(import-macros {: inspect : defns : pd/import} :source.lib.macros)

(defns :source.lib.helpers
  []

  (fn split [string sep]
    (let [matcher (.. "[^" sep  "]+")
          words []]
      (each [v (string.gmatch string matcher)]
        (table.insert words v))
      words))

  )
