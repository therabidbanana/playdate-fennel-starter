(import-macros {: defmodule} :source.lib.macros)


(if (not (?. _G.playdate :ui))
    (tset _G.playdate :ui {}))

(if (not (?. _G.playdate.ui :gridview))
    (tset _G.playdate.ui :gridview {}))

(defmodule _G.playdate.ui.gridview
 []
 ;; TODO: support multiple sections

 (fn setNumberOfRows [self num]
   (tset self :rows num))

 (fn setNumberOfColumns [self num]
   (tset self :cols num))

 (fn setCellSize [self width height]
   (tset self :grid-w width)
   (tset self :grid-h height)
   )

 (fn setContentInset [self left right top bottom]
   (let [right (or right left)
         top (or top right)
         bottom (or bottom top)]
     (tset self :inset :top top)
     (tset self :inset :bottom bottom)
     (tset self :inset :left left)
     (tset self :inset :right right)
     ))

 (fn setCellPadding [self left right top bottom]
   (let [right (or right left)
         top (or top right)
         bottom (or bottom top)]
     (tset self :padding :top top)
     (tset self :padding :bottom bottom)
     (tset self :padding :left left)
     (tset self :padding :right right)
     ))

 (fn drawInRect [self x y width height]
   ;; (tset self :cols num)
   (let [section 1
         width (if (<= self.grid-w 0)
                   width
                   self.grid-w)
         height self.grid-h
         inset self.inset
         padding self.padding
         ]
     (for [row 1 self.rows]
       ;; section 1, column 1...
       (let [column 1
             ;; TODO: handle scroll
             cell-x (+ inset.left (+ x (* width (- column 1))))
             cell-y (+ inset.top (+ y (* height (- row 1))))
             cell-h (+ height padding.top padding.bottom)
             cell-w (+ width padding.left padding.right)]
         (self:drawCell section row column (and (= row self.selected-row)
                                                (= column self.selected-col))
                        cell-x cell-y cell-w cell-h))
       ))
   )


 (fn getSelectedRow [self section]
   (?. self :selected-row))

 (fn selectNextRow [self wrap]
   ;; TODO: wrap
   (let [selected (?. self :selected-row)]
     (if (>= self.rows (+ 1 selected))
         (tset self :selected-row (+ 1 selected)))))

 (fn selectPreviousRow [self wrap]
   ;; TODO: wrap
   (let [selected (?. self :selected-row)]
     (if (>= (- selected 1) 1)
         (tset self :selected-row (- selected 1)))))

 (fn new [cell-width cell-height]
   (let [grid-w cell-width
         grid-h cell-height
         needsDisplay true
         padding {:top 0 :left 0 :bottom 0 :right 0}
         inset {:top 0 :left 0 :bottom 0 :right 0}
         scroll-x 0
         scroll-y 0
         selected-row 1
         selected-col 1
         rows 1
         cols 1]
     {: rows : cols : grid-w : grid-h
      : scroll-x : scroll-y : selected-row : selected-col
      : inset : padding
      : needsDisplay
      : drawInRect
      : setNumberOfRows : setNumberOfColumns : setCellSize
      : setCellPadding : setContentInset
      : getSelectedRow
      : selectNextRow : selectPreviousRow
      }
     )))
