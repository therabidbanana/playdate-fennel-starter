(import-macros {: pd/import : defns : inspect} :source.lib.macros)

(defns :minimal-test
  [pd playdate
   ;; $ui (require :source.lib.ui)
   gfx pd.graphics]

  (fn enter! [$]
    ;; ($ui:open-textbox! {:text (gfx.getLocalizedText "textbox.test2")})
    )

  (fn exit! [$])

  (fn tick! [$]
    )
  (fn draw! [$]
    ;; ($.layer.tilemap:draw 0 0)
    (gfx.drawTextInRect "Foobar test" 20 20 100 100)
    )
  )
