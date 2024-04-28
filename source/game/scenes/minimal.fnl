(import-macros {: pd/import : defns : inspect} :source.lib.macros)

(defns :minimal-test
  [pd playdate
   gfx pd.graphics]

  (fn enter! [$]
    )

  (fn exit! [$])

  (fn tick! [$]
    )
  (fn draw! [$]
    ;; ($.layer.tilemap:draw 0 0)
    (gfx.drawTextInRect "Foobar test" 20 20 100 100)
    )
  )
