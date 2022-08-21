# modula

A modular script framework for Dual Universe.

## About

This is a rewrite of a private framework that I developed during the beta-years of Dual Universe.

I've been meaning to open-source it for ages, but with the upcoming release of the game, and the fact that the Lua scripting API is finally getting some love (leading to some changes), I've decided that a ground-up rewrite makes more sense.

This is that rewrite.

**WORK IN PROGRESS**: As this is a rewrite, I am slowly porting and cleaning my original code. If you come across this project and think that it doesn't look like there's much here, check back later. I have about 30 modules in the original version of the code, but they haven't all been ported yet.

## Introduction

Modula is designed to take some of the tedium out of writing complex Dual Universe scripts, in a way that allows the code to:

- remain clean and modular
- be reused across different scripts and constructs
- be managed cleanly in source control
- be automatically packed into `.conf` and `.json` files (and potentially compacted)

## Requirements

This has been developed using WSL 2, with Ubuntu-20.04. You may be able to get things working with other environments, but that's the one I would recommend.

The pack script is itself written in Lua, so you will need lua, and lua-rocks installed (eg using apt install), and you will need to install `lfs` with Lua Rocks.

Installing git is not strictly necessary but probably a good idea.

For development I use VS Code. A build script is included which runs the pack script when you hit Ctrl-Shift-B. This automatically packs the complete script into a `.conf` file in `autoconf/custom`. It also writes a `.json` file to the same place.

## Modules

Modula is based around the idea of combining modules.

Each module in Modula is a Lua object that provides some functionality to the overall script. 

Modules are registered with the core. During registration a module can ask to respond to certain events and actions. They can also publish their services, to be used by other modules. 

The idea here that each module has a clearly defined tasks - such as showing an altimeter, managing auto-braking, managing the landing gear, controlling flight, etc. 

You can combine these modules in different ways to make the overall script that you want. 

You can also share these modules between multiple scripts.

If you want a different style of altimeter, you simply replace the altimeter module. If your ship doesn't have a warp drive, you don't bother with the warp module. Etc. 

When the script is finally packed up for distribution, only the code for the modules that were used is actually included.

## Core

The core is the glue that holds everything else together. It:

- loads and registers modules
- handles all events from DU, and sends them out to any module that has registered an interest
- detects all elements connected to the construct, in a way that makes it easy for a module to access the ones it needs.
- tracks the state of the keyboard and sends actions to modules in a clean way
- provides various utility scripts

With the exception of `unit.onStart`, all of the event handlers that are actually registered in DU are just stubs which call on to the core (the `unit.onStart` handler is a little more complex, as it is the one that sets up the core).



## Example

For an example script, see [this project](https://github.com/samedicorp/modula-test).

