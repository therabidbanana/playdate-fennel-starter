compile: source/**/*.fnl
	./support/build.sh

build: compile
	pdc -k source test.pdx
	cp source/*.ldtk test.pdx/

launch: build
	playdate test.pdx

clean:
	rm ./source/main.lua ./test.pdx

win-compile: source/**/*.fnl
	powershell.exe "./support/build.ps1"

win-love-compile: source/**/*.fnl
	powershell.exe "./support/buildlove.ps1"

win-love-launch: win-love-compile
	powershell.exe "love source"

win-build: win-compile
	powershell.exe "pdc -k source test.pdx"
	powershell.exe "cp source/*.ldtk test.pdx/"

win-launch: win-build
	powershell.exe "playdate test.pdx"

win-clean:
	powershell.exe -noprofile -command "& {rm ./source/main.lua}"
	powershell.exe -noprofile -command "& {rm ./test.pdx}"
