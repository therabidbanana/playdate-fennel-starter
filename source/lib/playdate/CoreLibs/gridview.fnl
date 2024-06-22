(import-macros {: defmodule} :source.lib.macros)


(if (not (?. _G.playdate :ui))
    (tset _G.playdate :ui {}))

(if (not (?. _G.playdate.ui :gridview))
    (tset _G.playdate.ui :gridview {}))

(defmodule _G.playdate.ui.gridview
  [animator (require :source.lib.playdate.CoreLibs.animator)]
 ;; TODO: support multiple sections

 (fn setNumberOfRows [self num]
   (tset self :rows num))

 (fn setNumberOfColumns [self num]
   (tset self :cols num))

 (fn setCellSize [self width height]
   (tset self :cell-w width)
   (tset self :cell-h height)
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

 ;; TODO: naive approach without sections
 (fn -relativeCoords [self cell-width row column section]
   (let [section 1
         inset self.inset
         padding self.padding
         height self.cell-h
         width cell-width]
     (values
      (+ inset.left (* width (- column 1))
         (* padding.left (- column 1))
         (* padding.right (- column 1))
         )
      (+ inset.top (* height (- row 1))
         (* padding.top (- row 1))
         (* padding.bottom (- row 1))
         )
      )))

 (fn -relativeSize [self full-width]
   (let [width (if (<= self.cell-w 0)
                   full-width
                   (+ self.inset.left self.inset.right
                      (* self.columns (+ self.padding.left self.padding.right self.cell-w))))
         height self.cell-h]
     (values
      ;; (+ self.inset.left self.inset.right (* ))
      (+ 0 width)
      (+ self.inset.top self.inset.bottom
         (* height self.rows)
         (* self.padding.top self.rows)
         (* self.padding.bottom self.rows)
         ))))

 (fn drawInRect [self x y width height]
   ;; (tset self :cols num)
   (let [section 1
         inset self.inset
         padding self.padding
         cell-w (if (<= self.cell-w 0)
                   (- width inset.left inset.right padding.left padding.right)
                   self.cell-w)
         cell-h self.cell-h
         (canvas-w canvas-h) (-relativeSize self width)
         canvas (love.graphics.newCanvas canvas-w canvas-h)
         quad   (love.graphics.newQuad (self.scroll-x:currentValue) (self.scroll-y:currentValue)
                                       width height canvas-w canvas-h)]
     (love.graphics.push :all)
     (love.graphics.setCanvas canvas)
     (for [row 1 self.rows]
       ;; section 1, column 1...
       (let [column 1
             (cell-x cell-y) (-relativeCoords self cell-w row column)
             ;; TODO: handle scroll
             ;; cell-x (+ inset.left (+ x (* width (- column 1))))
             ;; cell-y (+ inset.top (+ y (* height (- row 1))))
             ]
         (_G.playdate.graphics.pushContext)
         (self:drawCell section row column
                        (and (= row self.selected-row) (= column self.selected-col))
                        (+ cell-x padding.left) (+ cell-y padding.top)
                        cell-w cell-h)
         (_G.playdate.graphics.popContext)
         )
       )
     (love.graphics.pop)
     (love.graphics.draw canvas quad x y)
     )
   )


 (fn getSelectedRow [self section]
   (?. self :selected-row))

 ;; (fn scrollToCell [self section row column animated?]
 ;;   (let [curr-x (self.scroll-x:currentValue)
 ;;         curr-y (self.scroll-y:currentValue)
 ;;         (canvas-w canvas-h) (-relativeSize self self.cell-w)
 ;;         (target-x target-y) (-relativeCoords self self.cell-w row column)
 ;;         animated? (if (= nil animated?)
 ;;                       true
 ;;                       animated?)]
 ;;     (if animated?
 ;;         )
 ;;     ))

 (fn selectNextRow [self wrap scroll]
   (let [selected (?. self :selected-row)
         scroll (if (= nil scroll)
                    true
                    scroll)]
     (if (>= self.rows (+ 1 selected))
         (do
           (tset self :selected-row (+ 1 selected))
           ;; (if scroll (tset self :scroll-y (animator.new 300 (self.scroll-y:currentValue) (+ (self.scroll-y:currentValue) 30)
           ;;                                               playdate.easingFunctions.easeOutCubic)))
           )
         (and wrap (> (+ 1 selected) self.rows))
         (tset self :selected-row 1))
     ))

 (fn selectPreviousRow [self wrap]
   ;; TODO: scrolling
   ;; TODO: wrap
   (let [selected (?. self :selected-row)]
     (if (>= (- selected 1) 1)
         (tset self :selected-row (- selected 1)))))

 (fn new [cell-width cell-height]
   (let [cell-w cell-width
         cell-h cell-height
         needsDisplay true
         padding {:top 0 :left 0 :bottom 0 :right 0}
         inset {:top 0 :left 0 :bottom 0 :right 0}
         scroll-x (animator.new 0 0 0 playdate.easingFunctions.easeOutCubic)
         scroll-y (animator.new 0 0 0 playdate.easingFunctions.easeOutCubic)
         selected-row 1
         selected-col 1
         rows 1
         cols 1]
     {: rows : cols : cell-w : cell-h
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
