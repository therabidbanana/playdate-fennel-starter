compile: source/**/*.fnl
	powershell.exe "./support/build.ps1"

build: compile
	powershell.exe "pdc source test.pdx"

launch: build
	powershell.exe "playdate test.pdx"

clean:
	powershell.exe "rm test.pdx"
	powershell.exe "rm source/main.lua"
