(import-macros {: inspect : defns} :source.lib.macros)

(defns scene
  [{:player player-ent} (require :source.game.entities.core)
      scene-manager (require :source.lib.scene-manager)
      $ui (require :source.lib.ui)
      pd playdate
      gfx pd.graphics]

  (local state {})
  (fn enter! [$]
    ($ui:open-menu! {:options [{:text "Foo" :action #($ui:open-textbox! {:text "While Lua will automatically close an open file handle when it's garbage collected, GC may not run right away; with-open ensures handles are closed immediately, error or no, without boilerplate.

The usage is similar to let, except:

    destructuring is disallowed (symbols only on the left-hand side)
    every binding should be a file handle or other value with a :close method.

After executing the body, or upon encountering an error, with-open will invoke (value:close) on every bound variable before returning the results."})}
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

