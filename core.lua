
ModulaCore = {
}

function ModulaCore.new(settings)
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

return ModulaCore