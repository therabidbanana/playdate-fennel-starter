; Playdate object helpers and misc
(import-macros {: defns} :source.lib.macros)

(defns :basics []
  (local timestamp 0)

  (fn draw-fps [] "TODO")
  (fn love-update [] "TODO")

  (tset _G.playdate :drawFPS draw-fps)
  (tset _G.playdate :love-update love-update)
  )
