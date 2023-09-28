# Playdate Fennel Starter

This starter set is intended to allow use of the Fennel language on Playdate,
including some helper library stuff for structuring games.

I built this on a Windows machine but I'm used to Macs so some of the build system is weird (for example, the Makefile relies on some conventions on my Windows machine)

## What's Fennel?

Fennel is a Lua based lisp - https://fennel-lang.org/

## What's Playdate?

The Playdate is a tiny handheld game system that can be easily programmed in Lua.

# Build Process

Assuming lua, fennel, pdc and playdate (simulator) are set up on your PATH, the Makefile should handle this with "make launch".

You can also build a pdx for upload to a playdate device with "make build".

To get raw lua file for processing manually, run "make compile", which creates a source/main.lua file with all fennel inside.

## Prerequisites

You'll need to install lua and fennel tooling separately. I used lua-rocks to install fennel as a binary.

## Playdate SDK

Install the Playdate SDK from the website: https://play.date/dev

`pdc` and `playdate` are expected to be available on the path.

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
