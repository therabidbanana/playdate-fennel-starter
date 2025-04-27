# Playdate Fennel Starter

This starter set is intended to allow use of the Fennel language on Playdate,
including some helper library stuff for structuring games.

[Fennel](https://fennel-lang.org/) is a Lua-based lisp and [Playdate](https://play.date) is a commercial handheld device that is easily programmable in Lua, which means you can program for a real console in Lisp with this starter kit.

## Build Modes

There are two ways to compile the app, taking advantage of Fennel macros. One compiles to playdate compatible lua, while the other compiles to Love2d with a custom built simulator that enables export to the web.

The Playdate version is considered the canonical version, but the Love2d version is complete enough to run the games I've built so far using this framework. (All Playdate specific APIs have to be rebuilt/reimplemented with Love versions, so there are many stubbed API calls not built out or having bugs in them.)

### Playdate

Prerequisites:

* fennel (`brew install fennel` on Mac)
* luarocks (`brew install lunarocks` on Mac)
* lunajson (`sudo luarocks install lunajson` to install to default brew path)
* [Playdate SDK](https://play.date/dev) installed

`make compile` generates a source/main.lua that should be runnable on the playdate simulator.

`make build` to run main.lua through `pdc` and generate a playable pdx

`make launch` to open the pdx file. This relies on a `playdate` command, which you will need to set up to open the simulator either by linking (on mac) "open" or (on linux) "PlaydateSimulator" from the installed SDK.

### Love2d Compatible Mode

Prerequisites:

* fennel (`brew install fennel` on Mac)
* luarocks (`brew install lunarocks` on Mac)
* lunajson (`sudo luarocks install lunajson` to install to default brew path)
* [LÖVE](https://love2d.org/) installed to run the love version
* serve & love.js installed (`npm install`) if you want to do web build from love

`make love-compile` to generate source/main.lua appropriate for Love2d

`make love-launch` to run the main.lua as a love package direct from source

`make love-package` to build a .love (zip) file from source

`make love-web` to build a JS compiled version of the love-package

`make love-serve` to serve the JS version using `serve` (a lightweight http server)

**JS specific notes**

We use love.js to build the JS version - it requires special permissions headers to run on a site. Learn more here: https://github.com/Davidobot/love.js?tab=readme-ov-file#notes

## Love2d Compat Mode Notes

This framework allows compiling to a Love2d compatible lua file, with stubs for Playdate libraries and some wrappers to set up somewhate similar UI to playdate.

This is very much a work in progress, the only functions that have been replaced are the ones I've personally needed for game making. Available features:

1. Render in a similar aspect ratio
2. Render text (see build limitations)
3. Handle alternate fonts
3. Input handlers (just pressed & pressed)
  - Crank not yet supported
4. Render images
5. Sprite handling
6. Sprite collision support
7. Nine slice support
  - Nine slice bug - sides bleed into corners
8. Basic gridview support
  - Only list views tested
9. graphics context support
10. blinker support
11. Pathing lib
12. Sound support (see build limitations)

### Love2d Build Notes

* Love cannot play sounds encoded in wav format for playdate, you must re-encode as ogg and have it available in the same directory as the wav file
* Love cannot use playdate formatted .fnt files - there is a build step to convert to .bmfnt files (taken from the [Playbit](https://github.com/GamesRightMeow/playbit) library)

# Build Process Description

First we build a lua file from Fennel, then we compile it with Playdate's compiler to get a `.pdx` that can be run on Playdate. This means that Playdate only sees Lua code, not Fennel.

In the case of Love2d, we programmatically (using macros) compile a version of the main.lua file that is better suited for running in Love2d. This includes polyfills for the Playdate SDK and a frame that simulates the inputs available on a Playdate.

## Prerequisites

You'll need to install lua (luarocks) and fennel tooling separately.

For LDtk macro support, you'll also need to install "lunajson" via lua-rocks (alternatively, you can use the SDK's json loader to load the ldtk file in runtime).

## Playdate SDK

Install the Playdate SDK from the website: https://play.date/dev

`pdc` and `playdate` (alias for PlaydateSimulator) are expected to be available on the path.

### windows pdc/playdate:

Examples, assuming playdate sdk installed at C:\Users\David\Documents\PlaydateSDK

pdc.ps1 :

```
C:\Users\David\Documents\PlaydateSDK\bin\pdc.exe -I C:\Users\David\Documents\PlaydateSDK -k $args
```

playdate.ps1 :

```
C:\Users\David\Documents\PlaydateSDK\bin\PlaydateSimulator.exe $args
```
