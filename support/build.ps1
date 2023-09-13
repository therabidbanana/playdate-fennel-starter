$content = fennel -c --require-as-include "./source/main.fnl"
[IO.File]::WriteAllLines("./source/main.lua", $content)