;; Patch for missing require
(global package {:loaded {} :preload {}})
(fn _G.require [name]
  (if (not (. package.loaded name))
      (tset package.loaded name ((?. package.preload name))))
  (?. package.loaded name))
;; End patch for missing require

(import-macros {: inspect : pd/import : pd/load : love/patch} :source.lib.macros)
(love/patch)

(pd/import :CoreLibs/object)
(pd/import :CoreLibs/easing)
(pd/import :CoreLibs/graphics)
(pd/import :CoreLibs/sprites)
(pd/import :CoreLibs/timer)

(global $config {:debug true})

(pd/load
 [{: scene-manager} (require :source.lib.core)]
 (fn load-hook []
   (scene-manager:load-scenes! (require :source.game.scenes))
   (scene-manager:select! :menu)
   )
 (fn update-hook []
   (scene-manager:tick!)
   )
 (fn draw-hook []
   (scene-manager:draw!)
   )
 )

