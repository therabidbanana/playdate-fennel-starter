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
;;(let [font (gfx.getFont)
;;      greeting test.foo

;;      image  (playdate.graphics.tilemap.new)
;;      _ (image:setImageTable (playdate.graphics.imagetable.new "images/player"))
;;      _ (image:setTiles [2 1 2] 8)
;;      sprite player
;;      _ (sprite:setBounds 20 20 8 8)
;;      _ (sprite:setTilemap image)
;;      
;;      _ (sprite:add)
;;      w (font:getTextWidth greeting)
;;      h (font:getHeight)
;;      x 200
;;      y 200]
;;      
;;(set player sprite))
)

(setupGame)

(fn pd.update []
  (gfx.sprite.update)
  (pd.timer.updateTimers)
  (pd.drawFPS 0 0)  
)
 
