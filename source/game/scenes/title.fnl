(import-macros {: defns : inspect} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)


(deflevel :Level_0
  [{:player player-ent} (require :source.game.entities.core)
   ldtk (require :source.lib.ldtk.loader)
   {: prepare-level} (require :source.lib.level)
   pd playdate
   gfx pd.graphics]

  (fn enter! [$]
    (let [player (player-ent.new! 20 20)
          ;; Option 1 - Loads at runtime
          ;; loaded (prepare-level (ldtk.load-level {:level 0}))
          ;; Option 2 - relies on deflevel compiling
          loaded (prepare-level Level_0)
          layer (?. loaded :layers 1)
          bg (gfx.sprite.new)
          ]
      (bg:setTilemap layer.tilemap)
      (bg:setCenter 0 0)
      (bg:moveTo 0 0)
      (bg:setZIndex -100)
      (tset $ :layer layer)
      (player:add)
      (bg:add)
      (printTable (ldtk.load-level {:level 0}))
      )
    )

  (fn exit! [$])

  (fn tick! [$]
    (gfx.sprite.performOnAllSprites (fn react-each [ent]
                                      (if (?. ent :react!) (ent:react!)))))
  (fn draw! [$]
    ;; ($.layer.tilemap:draw 0 0)
    )
  )

