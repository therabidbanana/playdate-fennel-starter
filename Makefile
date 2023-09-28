compile: source/**/*.fnl
	./support/build.sh

build: compile
	pdc source test.pdx

launch: build
	playdate test.pdx

clean:
	rm ./source/main.lua ./test.pdx

win-compile: source/**/*.fnl
	powershell.exe "./support/build.ps1"

win-build: win-compile
	powershell.exe "pdc source test.pdx"

win-launch: win-build
	powershell.exe "playdate test.pdx"

win-clean:
	powershell.exe -noprofile -command "& {rm ./source/main.lua}"
	powershell.exe -noprofile -command "& {rm ./test.pdx}"
