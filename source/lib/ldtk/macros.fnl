(global LEVELS-FILE "source/levels.ldtk")
(local ldtk (require :source.lib.ldtk))

(fn defns [ns-name bindings & forms]
  (let [names (icollect [_ [t name & def] (ipairs forms)]
                (if (= t (sym :local)) name
                    (= t (sym :fn)) name))
        map (collect [_ name (ipairs names)]
              (values (tostring name) name))]

    `(let ,bindings
       ,forms
       ,map)))

(fn deflevel [levelname bindings & forms]
  (let [json (require :lunajson)
        file (with-open [f (io.open LEVELS-FILE)] (f:read "*all"))
        data (json.decode file)
        leveldata (ldtk.parse-level (ldtk.find-level data levelname)
                                    (ldtk.find-details data))]
    (table.insert bindings (sym levelname))
    (table.insert bindings leveldata)
    (defns levelname bindings (table.unpack forms))))

{: deflevel}
