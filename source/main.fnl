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

(local player-ent (require :source.entities.player))
(local pd playdate) 
(local gfx pd.graphics)

(var player nil)
(fn setupGame []
  (set player (player-ent.new! 20 20))
  (player:add)
)

(setupGame)

(fn pd.update []
  (gfx.sprite.update)
  (pd.timer.updateTimers)
  (pd.drawFPS 0 0)  
)
 
