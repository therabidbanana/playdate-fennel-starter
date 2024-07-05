# Playdate Fennel Starter

This starter set is intended to allow use of the Fennel language on Playdate,
including some helper library stuff for structuring games.

I built this on a Windows machine but I'm used to Macs so some of the build system is weird (for example, the Makefile relies on some conventions on my Windows machine)

## What's Fennel?

Fennel is a Lua based lisp - https://fennel-lang.org/

## What's Playdate?

The Playdate is a tiny handheld game system that can be easily programmed in Lua.

# Love2d Compat Mode

This framework allows compiling to a Love2d compatible lua file, with stubs for Playdate libraries and some wrappers to set up similar UI to playdate.

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

## Build Limitations

* Love cannot play sounds encoded in wav format for playdate, re-encode as ogg for better compatibility.
* Love cannot use playdate formatted .fnt files - there is a build step to convert to .bmfnt files (Playbit library)

# Build Process

Assuming lua, fennel, pdc and playdate (simulator) are set up on your PATH, the Makefile should handle this with "make launch".

You can also build a pdx for upload to a playdate device with "make build".

To get raw lua file for processing manually, run "make compile", which creates a source/main.lua file with all fennel inside.

## Prerequisites

You'll need to install lua and fennel tooling separately. I used lua-rocks to install fennel as a binary and scoop to install lua, lua-rocks & make on Windows.

For LDtk macro support, you'll also need to install "lunajson" via lua-rocks (alternatively, you can use the SDK's json loader).

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


### Building BM fonts for Love

Using script from Playbit framework - Example: 

---
lua "C:\Users\David\projects\game\fennel-test\support\love-font.lua" "C:\Users\David\projects\game\fennel-test\source\assets\fonts\Nontendo-Bold.fnt" "C:\Users\David\projects\game\fennel-test\source\assets\fonts\Nontendo-Bold-table-10-13.png" output.fnt -
---
