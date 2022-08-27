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

For development I use VS Code. A build script is included which runs the pack script when you hit Ctrl-Shift-B. This automatically packs the complete script into a `.conf` file in `autoconf/custom`. It also writes a `.json` file to the same place, and copies it into the clipboard.

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

## Events

Modules can register for events with the Modula core:

```lua
    modula:registerForEvents(self, "onStart", "onStop")
```

When the event occurs, the corresponding handler on the module will be called. 

Modules can also _generate_ events:

```lua
    modula:call("onMyEvent", "some parameter")
```

Any other modules that have registered will be called. 

This ability is useful for modules that need to synchronise their actions with other modules. 

For example, the windows module manages creating html screen content. It calls `onUpdateWindows` to ask other modules to update their window content. Any module interested in displaying a window registers for this event. When a module gets the event, it calls the windows module back to provide some content. The screen module then combines the content of all windows into the final screen html.

## Services

Some modules provide services to other modules, but don't do so using events.

These modules can register themselves with the core:

```lua
    modula:registerService(self, "panels")
```

Any other module that needs the "panels" service can find it, without having to know exactly what module is providing it:

```lua
    local panels = modula:getService("panels")
```

This provides full decoupling between the service and its implementation. 

Your construct script can be configured to use one implementation of the "panels" service, then changed later to use a different one. As long as both services provide the same API, everything will continue to work.


## Actions

For the most part, keyboard handling with modula just requires add some configuration to the `actions` property of the settings.

For each of the actions that you want to handle, you specify a record. 

The `target` property of this record specifies the service name that will be called when the action happens.

The other properties specify the name of the handler to call, and when to call it:

- `start`: calls the named handler on action start
- `stop`: calls the named handler on action stop
- `onoff`: calls the named handler on start and stop
- `loop`: calls the named handler on whilst the action is looping
- `long`: calls the named handler if the action is long-pressed

Here's a full example:

```lua
actions = {
        brake = {
            target = "test",
            start = "startTest",
            stop = "stopTest"
        },


        option1 = {
            target = "test",
            onoff = "startStopTest",
        },

        option2 = {
            target = "test",
            loop = "loopTest"
        },

        gear = {
            target = "test",
            stop = "normalPressTest",
            long = "longPressTest"
        },
    }
```

## Existing Modules

- **panels**: Implements a panel-management service, with a clean API for creating panels, adding widgets to them, updating them, showing/hiding them dynamically.
- **windows**: Implements a service that allows you to display "windows" on the screen. Each window is a chunk of html/svg. The service registers timers and sends events which other modules can register for to update their window content, and then collates all the content and places it on the screen.
- **console**: This module uses a linked screen as a debug console. All output from the modula `debugf` and `printf` functions is echoed to the screen. Useful for the development.
- **screen**: Implements a service which supports an input/output loop for screens. You can use the service to send a table to a screen. The service automatically encodes the table as json, and installs lua into the screen which decodes the json back into a table. Output from the screen back to the client module is handled in the same manner. When you use the service to link to a screen you supply some custom lua which is handed the input table and can pass back an output table.


### UI Modules Which Will Likely Be Ported
- airspeed
- altimeter
- fuel
- horizon
- indicators
- logo
- status
- throttle

### Control Modules Which Will Likely Be Ported
- attitude
- autogear
- autohatch
- autotarget
- bookmarks
- braking
- container
- debug
- dynamic
- flightassist
- ground
- impulse
- industry
- industrySupport
- installedSchematics
- kinematics
- mining
- parking
- radar
- refinery
- schematics
- stabilisation
- throttle
- vtol
- warp

### Other Planned Modules

- notifications: allows you to post notifications which other modules display


## Example

For an example script, see [this project](https://github.com/samedicorp/modula-test).

