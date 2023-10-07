(import-macros {: defns : inspect} :source.lib.macros)

(defns :$ui
  [menu (require :source.lib.ui.menu)
   text (require :source.lib.ui.textbox)]

  (local stack [])
  (fn push-component! [$ui comp]
    (table.insert $ui.stack comp)
    )
  (fn pop-component! [$ui]
    (table.remove $ui.stack))

  (fn render! [$ui]
    (each [i v (ipairs $ui.stack)]
      (v:render! $ui)))

  (fn tick! [$ui]
    (let [v (?. $ui.stack (length $ui.stack))]
      (if (= v nil) v (v:tick! $ui))))

  (fn active? [$ui]
    (> (length $ui.stack) 0))

  (fn open-menu! [$ui props]
    ($ui:push-component! (menu:new! $ui props))
    )
  (fn open-textbox! [$ui props]
    ($ui:push-component! (text:new! $ui props))
    )
  )
