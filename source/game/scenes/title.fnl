(import-macros {: inspect} :source.lib.macros)
(let [{:player player-ent} (require :source.game.entities.core)
      pd playdate
      gfx pd.graphics]
  {:enter! (fn scene-enter! [$]
             (var player nil)
             (set player (player-ent.new! 20 20))
             (player:add))
   :exit! (fn scene-exit! [$])
   :tick! (fn scene-tick! [$]
            ;; (listview:drawInRect 180 20 200 200)
            (gfx.sprite.performOnAllSprites (fn react-each [ent]
                                              (if (?. ent :react!) (ent:react!)))))
   :draw! (fn scene-tick! [$]
            ;; (listview:drawInRect 180 20 200 200)
            )})

