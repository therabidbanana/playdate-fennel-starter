APP_NAME := test

compile: source/**/*.fnl
	fennel -c --require-as-include --no-compiler-sandbox source/main.fnl > source/main.lua

build: compile
	pdc -k source ${APP_NAME}.pdx
	cp source/*.ldtk ${APP_NAME}.pdx/

launch: build
	playdate ${APP_NAME}.pdx

love-compile: source/**/*.fnl
	fennel --add-package-path './support/?.lua' support/build-font.fnl
	fennel --load ./source/lib/love-flags.fnl -c --require-as-include --no-compiler-sandbox ./source/main.fnl > source/main.lua

love-launch: love-compile
	love source

love-package: love-compile
	rm -f app.zip
	rm -f ${APP_NAME}.love
	cd source && \
	zip -vr ../app.zip main.lua *.strings assets/ -x "*.DS_Store"
	mv app.zip ${APP_NAME}.love

love-web: love-package
	npx love.js -m 134217728 -t '${APP_NAME}' ${APP_NAME}.love dist

love-serve: love-web
	npx serve -C -c ../serve.json -p 8000 dist

clean:
	rm -rf ./source/main.lua ./${APP_NAME}.pdx dist ./${APP_NAME}.love
