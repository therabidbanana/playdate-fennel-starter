APP_NAME := test

compile: source/**/*.fnl
	./support/build.sh

build: compile
	pdc -k source ${APP_NAME}.pdx
	cp source/*.ldtk ${APP_NAME}.pdx/

launch: build
	playdate ${APP_NAME}.pdx

clean:
	rm ./source/main.lua ./${APP_NAME}.pdx

win-compile: source/**/*.fnl
	powershell.exe "./support/build.ps1"

win-love-compile: source/**/*.fnl
	powershell.exe "fennel --add-package-path './support/?.lua' .\support\build-font.fnl"
	powershell.exe "./support/buildlove.ps1"

win-love-launch: win-love-compile
	powershell.exe "love source"

win-love-package: win-love-compile
	powershell.exe -noprofile -command "& {rm ./app.zip}"
	powershell.exe -noprofile -command "& {rm ./${APP_NAME}.love}"
	powershell.exe "./support/packagelove.ps1"
	powershell.exe "mv app.zip ${APP_NAME}.love"

win-love-web: win-love-package
	powershell.exe "npx love.js.cmd -t Playdate -c .\${APP_NAME}.love dist"

win-love-serve: win-love-web
	powershell.exe "Start-Process powershell.exe 'python -m http.server 8000 -d dist'"
	powershell.exe "Start-Process 'http://localhost:8000'"

win-build: win-compile
	powershell.exe "pdc -k source ${APP_NAME}.pdx"
	powershell.exe "cp source/*.ldtk ${APP_NAME}.pdx/"

win-launch: win-build
	powershell.exe "playdate ${APP_NAME}.pdx"

win-clean:
	powershell.exe -noprofile -command "& {rm ./source/main.lua}"
	powershell.exe -noprofile -command "& {rm ./${APP_NAME}.pdx}"
