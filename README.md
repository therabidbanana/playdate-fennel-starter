# Playdate Fennel Starter

This starter set is intended to allow use of the Fennel language on Playdate,
including some helper library stuff for structuring games.

I built this on a Windows machine but I'm used to Macs so some of the build system is weird (for example, the Makefile relies on some conventions on my Windows machine)

## What's Fennel?

Fennel is a Lua based lisp - https://fennel-lang.org/

## What's Playdate?

The Playdate is a tiny handheld game system that can be easily programmed in Lua.

# Love2d Compat Mode

**WORK IN PROGRESS**

This framework allows compiling to a Love2d compatible lua file, with stubs for Playdate libraries and some wrappers to set up similar UI to playdate.

This is very much a work in progress, most of the functions are still stubbed and the render is nothing alike.

Features to add next:

<!-- 1. Render in a similar aspect ratio -->
2. Render text lib that works like playdate
<!-- 3. Input handlers (look at how Playbit does it) -->
<!-- 4. Render image -->
<!-- 5. Sprite handling -->
6. Sprite collision support
7. Nine slice support
8. scrolling in gridview
9. graphics context support (use in gridview)

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
