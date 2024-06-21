(import-macros {: div : inspect : defmodule} :source.lib.macros)

(if (not (?. _G.playdate :graphics))
    (tset _G.playdate :graphics {}))

(if (not (?. _G.playdate :graphics :imagetable))
    (tset _G.playdate :graphics :imagetable {}))

(defmodule _G.playdate.graphics.imagetable
  [{: split} (require :source.lib.helpers)]

  (fn getImage [{: quads : atlas} n]
    {:draw (fn [x y]
             ;; (love.graphics.push :all)
             ;; (love.graphics.setColor 1 1 1 1)
             (love.graphics.draw atlas (?. quads n) x y)
             ;; (love.graphics.pop)
             )}
    )

  (fn drawImage [{: quads : atlas} n x y]
    ;; (love.graphics.push :all)
    ;; (love.graphics.setColor 1 1 1 1)
    (love.graphics.draw atlas (?. quads n) x y)
    ;; (love.graphics.pop)
    )

  (fn new [path]
    ;; TODO: windows compat?
    (let [parts (split path "/")
          file  (table.remove parts)
          dir   (table.concat parts "/")

          ;; Clean out table if already included, then create a matcher
          prefix (: (.. (file:gsub "%-table%-%d+%-%d+%.png" "")
                      "-table-%d+-%d+%.png")
                   :gsub "%-" "%%-")
          all-files (love.filesystem.getDirectoryItems dir)
          matching  (?. (icollect [i v (ipairs all-files)]
                          (if (string.match v prefix) v)) 1)
          ]
      (if matching
          (let [(w h) (string.match matching "%-(%d+)%-(%d+)" 2)
                full-file (.. dir "/" matching)
                atlas (love.graphics.newImage full-file)
                atlas-width (atlas:getWidth)
                total-w (div atlas-width w)
                atlas-height (atlas:getHeight)
                total-h (div atlas-height h)
                quads []
                ]
            (for [y 0 (- total-h 1)]
              (for [x 0 (- total-w 1)]
                (table.insert quads (love.graphics.newQuad (* x w) (* y h)
                                                           w h
                                                           atlas-width atlas-height))))
            {:tile-w w :tile-h h
             : quads : atlas
             : getImage : drawImage }
            )
          (print "WARN: No file available matching"))
      ))
  )
