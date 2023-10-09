$content = fennel -c --require-as-include --no-compiler-sandbox "./source/main.fnl"
[IO.File]::WriteAllLines("./source/main.lua", $content)
