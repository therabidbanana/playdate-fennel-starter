(import-macros { : pd/import : defns : inspect} :source.lib.macros)

;; This dynamically loads levels created via ldtk
;;
;; The macro approach is more complicated but compiles to lua datastructures at
;; compile
(defns :source.lib.ldtk-loader
  [gfx playdate.graphics
   ldtk (require :source.lib.ldtk)]

  (fn load-world [{ : filename}]
    (let [filename (or filename "levels.ldtk")]
      (json.decodeFile filename)))

  (fn load-level [{ : filename : level &as args}]
    (let [world (load-world args)
          level-data (ldtk.find-level world level)]
      (ldtk.parse-level level-data)))
  )

