(fn printTable [tbl#]
  (fn tostr# [val#]
    (if (= (type val#) :table)
        (.. "{"
            (table.concat (icollect [i# v# (pairs val#)]
                            (.. i# " = " (or (tostr# v#) "nil"))) "\n")
            "}")
        (= (type val#) :function)
        "(fn [])"
        (= (type val#) :boolean)
        (if val# "true" "false")
        (= (type val#) :userdata)
        "(love internal)"
        val#
        ))
  (print (tostr# tbl#))
  )

(let [fs (require :filesystem)
      lf (require :love-font)]
  (each [i img (ipairs (fs.getFiles "source/assets/fonts/"))]
    (if (img:find "-table-")
        (let [orig-img img
              orig-fnt (img:gsub "%-table%-%d+%-%d+%.png" ".fnt")
              output   (img:gsub "%-table%-%d+%-%d+%.png" ".bmfnt")]
          (print (.. "Building " output))
          (lf.convert orig-fnt orig-img output)
          ))
    )
  )
