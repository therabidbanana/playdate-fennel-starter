(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :ui))
    (tset _G.playdate :ui {}))

(defmodule _G.playdate.ui
  [gridview (require :source.lib.playdate.CoreLibs.gridview)]
  )
