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

## Example

For an example script, see [this project](https://github.com/samedicorp/modula-test).

