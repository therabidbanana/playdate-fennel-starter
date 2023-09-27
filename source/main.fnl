;; Patch for missing require, weird import
(print "Installing fake require & import support...")
(global package {:loaded {} :preload {}})
(fn _G.require [name] 
  (if (not (. package.loaded name))
    (tset package.loaded name ((?. package.preload name))))
  (?. package.loaded name))
(macro pd/import [lib] `(lua ,(.. "import \"" lib "\"")))
;; End patch for missing require, weird import

(pd/import "CoreLibs/object")
(pd/import "CoreLibs/graphics")
(pd/import "CoreLibs/sprites")
(pd/import "CoreLibs/timer")
(pd/import "CoreLibs/ui")
(pd/import "CoreLibs/nineslice")

(import-macros {: inspect } :source.lib.macros)

(let [{: scene-manager} (require :source.lib.core)
      pd playdate
      gfx pd.graphics
      blocky (gfx.getSystemFont)]

  (scene-manager:load-scenes! (require :source.game.scenes.core))

  (fn setupGame []
    (scene-manager:select! :menu)
    ;; (set listview (testScroll))
    )

  (setupGame)

  (fn pd.update []
    (scene-manager:tick!)
    (scene-manager:draw!)
    ))
