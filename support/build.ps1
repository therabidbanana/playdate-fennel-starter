$content = fennel -c "./source/main.fnl"
[IO.File]::WriteAllLines("./source/main.lua", $content)