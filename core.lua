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
    print("started")
    
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

    _G.print = function(format, ...)
        if type(format) == "table" then
            for k,v in pairs(format) do
                system.print(string.format("%s: %s", k, v))
            end
        else
            system.print(format:format(...))
        end
    end

    -- if self._logging then
    --     _G.debug = _G.print
    -- else
    --     _G.debug = function() end
    -- end

    system.print("blah")

    -- _G.logf = function(s,...)
    --     local message = s:format(...) 
    --     system.logInfo(string.format("§±%s±§", message))
    -- end

    -- _G.warning = function(s, ...)
    --     printf("WARNING: %s", s:format(...))
    -- end

    -- _G.fail = function(s, ...)
    --     local message = s:format(...)
    --     system.showScreen(1)
    --     system.setScreen(string.format('<div class="window" style="position: absolute; top="10vh"; left="45vw"; width="10vw"><h1 style="middle">Error</h1><span>%s</span></div>', message))
    -- end
end

function ModulaCore:log(item)
    print(item)
end

return ModulaCore