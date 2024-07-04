(import-macros {: defmodule : inspect} :source.lib.macros)

(if (not (?. _G.playdate :keyboard))
    (tset _G.playdate :keyboard {}))

(defmodule
 _G.playdate.keyboard
 []

 ;; TODO: text settable?
 (local text "")
 (local keyboardWillHideCallback false)
 (local keyboardDidHideCallback false)
 (local keyboard-state {:open? false})

 (fn -closeKeyboard [enter?]
   (if _G.playdate.keyboard.keyboardWillHideCallback
       (_G.playdate.keyboard.keyboardWillHideCallback enter?)
       (inspect _G.playdate.keyboard))
   (tset keyboard-state :open? false)
   (love.keyboard.setTextInput false)
   (set love.textinput nil)
   (set love.keypressed keyboard-state.keypressed-fn)
   (if _G.playdate.keyboard.keyboardDidHideCallback
       (_G.playdate.keyboard.keyboardDidHideCallback))
   )

 (fn -handleTextInput [t]
   (let [curr-text _G.playdate.keyboard.text]
     (tset _G.playdate :keyboard :text (.. curr-text t))))


 (fn -handleKeypress [t]
   (case t
     "return"
     (-closeKeyboard true)
     "backspace"
     (tset _G.playdate :keyboard :text (_G.playdate.keyboard.text:sub 1 (- (length _G.playdate.keyboard.text) 1)))
     "escape"
     (-closeKeyboard false)
     ))

 (fn show [t]
   (tset _G.playdate :keyboard :text t)
   (tset keyboard-state :open? true)
   (tset keyboard-state :keypressed-fn love.keypressed)
   (love.keyboard.setTextInput true)
   (set love.textinput -handleTextInput)
   (set love.keypressed -handleKeypress)
   )

 (fn -maybeDraw []
   (if (?. keyboard-state :open?)
       (do
         (love.graphics.push :all)
         (love.graphics.setColor 0 0 0 1)
         (love.graphics.rectangle "fill" 240 0 160 240)
         (let [mode (playdate.graphics.getImageDrawMode)]
           (love.graphics.setColor 1 1 1 1)
           (playdate.graphics.setImageDrawMode "fillWhite")
           (love.graphics.printf "Typing..." 260 20 80)
           (playdate.graphics.setImageDrawMode mode))
         (love.graphics.pop)
         )
       )
   )
 )
