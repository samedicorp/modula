ModulaCore = {
}

function ModulaCore.new(system, library, player, construct, unit, settings)
    settings = settings or {}
    local instance = {
        _modules = {},
        _actions = {},
        _state = {},
        _skipLoader = settings.devMode or false,
        _logging = settings.logging or false,
        _logElements = settings.logElements or false,
        _logActions = settings.logActions or false,
        _timers = { },
    }

    setmetatable(instance, { __index = ModulaCore })

    instance:setupGlobals(system, library, player, construct, unit)
    debug("modula: initialised")
    
    return instance
end

function ModulaCore:onStart()
end

function ModulaCore:onStop()
end

function ModulaCore:onActionStart(action)
end

function ModulaCore:onActionLoop(action)
end

function ModulaCore:onActionStop(action)
end

function ModulaCore:onUpdate()
end

function ModulaCore:onFlush()
end

function ModulaCore:onInput(text)
end

function ModulaCore:setupGlobals(system, library, player, construct, unit)
    _G.system = _G.system or system
    _G.unit = _G.unit or unit
    _G.library = _G.library or library
    _G.player = _G.player or player
    _G.construct = _G.construct or construct

    _G.toString = function(item)
        if type(item) == "table" then
            local text = {}
            for k,v in pairs(item) do
                table.insert(text, string.format("%s: %s", k, toString(v)))
            end
            return "{ " .. table.concat(text, ", ") .. " }"
        else
            return tostring(item)
        end
    end

    _G.print = function(format, ...)
        local t = type(format)

        if type(format) == "string" then
            system.print(format:format(...))
        else
            system.print(toString(format))
            for i,a in ipairs({ ... }) do
                system.print(toString(a))
            end
        end
    end

    if self._logging then
        _G.debug = _G.print
    else
        _G.debug = function(format, ...) end
    end

    _G.log = function(format,...)
        local message = format:format(...) 
        system.logInfo(string.format("§±%s±§", message))
    end

    _G.warning = function(format, ...)
        print("WARNING: %s", format:format(...))
    end

    _G.fail = function(format, ...)
        local message = format:format(...)
        system.showScreen(1)
        system.setScreen(string.format('<div class="window" style="position: absolute; top="10vh"; left="45vw"; width="10vw"><h1 style="middle">Error</h1><span>%s</span></div>', message))
    end
end

return ModulaCore