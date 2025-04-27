(import-macros {: defmodule : inspect} :source.lib.macros)

(if (not (?. _G.playdate :sound))
    (tset _G.playdate :sound {}))

(if (not (?. _G.playdate :sound :fileplayer))
    (tset _G.playdate :sound :fileplayer {}))

(if (not (?. _G.playdate :sound :sampleplayer))
    (tset _G.playdate :sound :sampleplayer {}))


(defmodule
  _G.playdate.sound
  []
  (local
   sampleplayer
   (defmodule
     _G.playdate.sound.sampleplayer
     []

     (fn stop [self]
       (self.sound:stop))

     (fn play [self]
       (self.sound:play)
       )

     (fn isPlaying [self]
       (self.sound:isPlaying)
       )

     (fn new [file]
       (let [sound (love.audio.newSource (.. file :.ogg) :static)
             obj {: sound}]
         (setmetatable obj {:__index _G.playdate.sound.sampleplayer})
         obj)))
   )
  (local
   fileplayer
   (defmodule
     _G.playdate.sound.fileplayer
     []

     (fn setVolume [self val]
       (self.sound:setVolume val))

     (fn stop [self]
       (self.sound:stop))

     (fn play [self repeats]
       (if (= repeats 0)
           (self.sound:setLooping true))
       (self.sound:play)
       )

     (fn isPlaying [self]
       (self.sound:isPlaying)
       )

     (fn new [file]
       (let [sound (love.audio.newSource (.. file :.ogg) :stream)
             obj {: sound}]
         (setmetatable obj {:__index _G.playdate.sound.fileplayer})
         obj)
       )
     )
   )
  )
