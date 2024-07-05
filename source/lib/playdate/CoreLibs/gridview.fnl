(import-macros {: defmodule : inspect : div} :source.lib.macros)


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
      (+ ;;inset.left
         (* width (- column 1))
         (* padding.left (- column 1))
         (* padding.right (- column 1))
         )
      (+ ;;inset.top
         (* height (- row 1))
         (* padding.top (- row 1))
         (* padding.bottom (- row 1))
         )
      )))

 (fn -relativeSize [self full-width]
   (let [width (if (<= self.cell-w 0)
                   full-width
                   (+ 0
                      ;;self.inset.left self.inset.right
                      (* self.columns (+ self.padding.left self.padding.right self.cell-w))))
         height self.cell-h]
     (values
      (+ 0 width)
      (+ ;;self.inset.top self.inset.bottom
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
         outer  (love.graphics.newCanvas width height)
         canvas (love.graphics.newCanvas canvas-w canvas-h)
         viewport-w (- width inset.left inset.right)
         viewport-h (- height inset.top inset.bottom)
         max-scroll-x (- canvas-w viewport-w)
         max-scroll-y (- canvas-h viewport-h)
         scroll-x (math.max (math.min (self.scroll-x:currentValue) max-scroll-x) 0)
         scroll-y (math.max (math.min (self.scroll-y:currentValue) max-scroll-y) 0)
         quad   (love.graphics.newQuad (math.floor scroll-x) (math.floor scroll-y)
                                       viewport-w viewport-h
                                       canvas-w canvas-h)
         outerquad (love.graphics.newQuad 0 0 width height width height)
         ]
     (if self.scroll-target
         (let [new-scroll-x (- (* (+ padding.left cell-w padding.right) (- self.scroll-target.col 1))
                               (if self.scroll-target.center (div (- width cell-w padding.left padding.right) 2) 0))
               new-scroll-y (- (* (+ padding.top cell-h padding.bottom) (- self.scroll-target.row 1))
                               (if self.scroll-target.center (div (- height cell-h padding.top padding.bottom) 2) 0))]
           (tset self :scroll-target nil)
           (self:setScrollPosition new-scroll-x new-scroll-y)
           )
         )
     (love.graphics.push :all)
     (love.graphics.setCanvas outer)
     (love.graphics.push :all)
     (love.graphics.setCanvas canvas)
     (for [row 1 self.rows]
       ;; section 1, column 1...
       (let [column 1
             (cell-x cell-y) (-relativeCoords self cell-w row column)
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
     (if self.backgroundImage
         (self.backgroundImage:drawInRect 0 0 width height))
     (love.graphics.draw canvas quad inset.left inset.top)
     (love.graphics.pop)
     (love.graphics.draw outer outerquad x y)
     )
   )


 (fn getSelectedRow [self section]
   (?. self :selected-row))

 (fn setScrollPosition [self x y animated?]
   (let [curr-x (self.scroll-x:currentValue)
         curr-y (self.scroll-y:currentValue)
         easing self.scrollEasingFunction
         duration (if (= nil animated?)
                      self.scrollDuration
                      animated?
                      self.scrollDuration
                      1)]
     (tset self :scroll-x (animator.new duration curr-x x easing))
     (tset self :scroll-y (animator.new duration curr-y y easing))
     ))

 (fn selectNextRow [self wrap scroll]
   (let [selected (?. self :selected-row)
         scroll (if (= nil scroll)
                    true
                    scroll)]
     (if (>= self.rows (+ 1 selected))
         (tset self :selected-row (+ 1 selected))
         (and wrap (> (+ 1 selected) self.rows))
         (tset self :selected-row 1))
     (if scroll (tset self :scroll-target {:row self.selected-row :col self.selected-col
                                           :center true}))
     ))

 (fn selectPreviousRow [self wrap scroll]
   (let [selected (?. self :selected-row)
         scroll (if (= nil scroll)
                    true
                    scroll)]
     (if (>= (- selected 1) 1)
         (tset self :selected-row (- selected 1))
         (and wrap (< (- selected 1) 1))
         (tset self :selected-row self.rows))
     (if scroll (tset self :scroll-target {:row self.selected-row :col self.selected-col
                                           :center true}))))

 (fn new [cell-width cell-height]
   (let [cell-w cell-width
         cell-h cell-height
         needsDisplay true
         padding {:top 0 :left 0 :bottom 0 :right 0}
         inset {:top 0 :left 0 :bottom 0 :right 0}
         scrollEasingFunction playdate.easingFunctions.easeOutCubic
         scrollDuration 250
         scroll-x {:currentValue (fn [] 0)}
         scroll-y {:currentValue (fn [] 0)}
         selected-row 1
         selected-col 1
         rows 1
         cols 1]
     {: rows : cols : cell-w : cell-h
      : scroll-x : scroll-y : selected-row : selected-col
      : inset : padding
      : needsDisplay
      : drawInRect
      : scrollEasingFunction : setScrollDuration : scrollDuration : setScrollPosition
      : setNumberOfRows : setNumberOfColumns : setCellSize
      : setCellPadding : setContentInset
      : getSelectedRow
      : selectNextRow : selectPreviousRow
      }
     )))
