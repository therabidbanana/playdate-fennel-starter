(lua "import \"CoreLibs/object\"")
(lua "import \"CoreLibs/graphics\"")
(lua "import \"CoreLibs/sprites\"")
(lua "import \"CoreLibs/timer\"")

;; Patch for missing require
(global package {:loaded {} :preload {}})
(fn _G.require [name] 
  (if [(not (. package.loaded name))]
    (tset package.loaded name ((?. package.preload name))))
  (?. package.loaded name))
;; End patch for missing require

(local test (require :source.test))
(local pd playdate) 
(local gfx pd.graphics)

(fn setupGame []
  (let [font (gfx.getFont)
        greeting test.foo
        w (font:getTextWidth greeting)
        h (font:getHeight)
        x 200
        y 200]
        (gfx.drawText greeting x y))
)

(setupGame)

(fn pd.update []
  (gfx.sprite.update)
  (pd.timer.updateTimers)
  (pd.drawFPS 0 0)  
)
 
