(import-macros {: pd/import : defns : inspect} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)

(deflevel :level_0
  [{:player player-ent} (require :source.game.entities.core)
   ;; ldtk (require :source.lib.ldtk.loader)
   {: prepare-level!} (require :source.lib.level)
   pd playdate
   gfx pd.graphics]

  (fn enter! [$]
    (let [entity-map {:player_start player-ent}
          ;; Option 1 - Loads at runtime
          ;; loaded (prepare-level! (ldtk.load-level {:level 0}) entity-map)
          ;; Option 2 - relies on deflevel compiling
          loaded (prepare-level! level_0 entity-map)
    ]
      loaded
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

