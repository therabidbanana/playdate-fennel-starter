(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :menu))
    (tset _G.playdate :menu {}))

(defmodule _G.playdate.menu
  []
  (local state {:items []})

  (fn addMenuItem [title callback]
    (table.insert state.items {: title : callback}))

  (fn getMenuItems []
    [])

  (fn getSystemMenu []
    {: addMenuItem : getMenuItems}
    )

  ;; TODO: Implement system menu fake
  (fn trigger! [])

  (tset _G.playdate :getSystemMenu getSystemMenu)
  )
