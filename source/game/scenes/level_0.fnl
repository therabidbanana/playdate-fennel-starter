(import-macros {: pd/import : defns : inspect} :source.lib.macros)
(import-macros {: deflevel} :source.lib.ldtk.macros)

(deflevel :level_0
  [entity-map (require :source.game.entities.core)
   ;; ldtk (require :source.lib.ldtk.loader)
   {: prepare-level!} (require :source.lib.level)
   $ui (require :source.lib.ui)
   pd playdate
   gfx pd.graphics]

  (fn enter! [$]
    (let [
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
    (if ($ui:active?) ($ui:tick!)
        (gfx.sprite.performOnAllSprites (fn react-each [ent]
                                          (if (?. ent :react!) (ent:react!))))))
  (fn draw! [$]
    ;; ($.layer.tilemap:draw 0 0)
    ($ui:render!)
    )
  )

