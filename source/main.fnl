(lua "import \"CoreLibs/object\"")
(lua "import \"CoreLibs/graphics\"")
(lua "import \"CoreLibs/sprites\"")
(lua "import \"CoreLibs/timer\"")

(local pd playdate)
(local gfx pd.graphics)

(fn setupGame []
  (let [font (gfx.getFont)
        greeting "awesome sauce!"
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
 
