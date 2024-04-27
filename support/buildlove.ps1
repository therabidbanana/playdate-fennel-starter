$content = fennel --load "./source/lib/love-flags.fnl" -c --require-as-include --no-compiler-sandbox "./source/main.fnl"
[IO.File]::WriteAllLines("./source/main.lua", $content)
