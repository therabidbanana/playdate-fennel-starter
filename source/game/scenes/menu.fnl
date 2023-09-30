(import-macros {: inspect : defns} :source.lib.macros)

(defns scene
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})
  (fn enter! [$]
    ($ui:open-menu! {:options [{:text "Foo"}
                               {:text "Bar [!]" :action #(scene-manager:select! :title)}
                               {:text "Quux"}
                               {:text "Qux" :keep-open? true}
                               {:text "Corge"}
                               {:text "Grault"}
                               {:text "Garply"}
                               ]})
    ;; (tset $ :state :listview (testScroll pd gfx))
    )
  (fn exit! [$]
    (tset $ :state {}))
  (fn tick! [{:state {: listview} &as $}]
    ;; (listview:drawInRect 180 20 200 200)
    (if ($ui:active?) ($ui:tick!)
        (let [pressed? playdate.buttonJustPressed]
          (if (pressed? playdate.kButtonA) (scene-manager:select! :title)))
        (gfx.sprite.performOnAllSprites (fn react-each [ent]
                                          (if (?. ent :react!) (ent:react!))))))
  (fn draw! [{:state {: listview} &as $}]
    ($ui:render!)
    ;; (listview:drawInRect 180 20 200 200)
    )
  )

