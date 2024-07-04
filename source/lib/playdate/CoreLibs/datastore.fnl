(import-macros {: defmodule} :source.lib.macros)

(if (not (?. _G.playdate :datastore))
    (tset _G.playdate :datastore {}))

(defmodule
 _G.playdate.datastore
 [json (require :source.lib.playdate.CoreLibs.json)]

 (fn read [id]
   (let [id (or id "default")
         file (.. id ".datastore")]
     (if
      (love.filesystem.getInfo file)
      (let [file-str (love.filesystem.read file)]
        (json.decode file-str)))))

 (fn delete [id]
   (let [id (or id "default")
         file (.. id ".datastore")]
     (if
      (love.filesystem.getInfo file)
      (love.filesystem.remove file))))

 (fn write [data id]
   (let [id (or id "default")
         file (.. id ".datastore")
         file-str (json.encode data)]
     (love.filesystem.write file file-str)))
 )
