-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 20/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
ModulaCore = {
    class = "ModulaCore"
}

function ModulaCore.new(system, library, player, construct, unit, settings)
    settings = settings or {}
    local instance = {
        _modules = settings.modules or {},
        _moduleNames = {},
        _moduleIndex = {},
        _actions = {},
        _elements = {},
        _state = {},
        _skipLocal = settings.devMode or false,
        _logging = settings.logging or false,
        _logElements = settings.logElements or false,
        _logActions = settings.logActions or false,
        _timers = {},
        _handlers = {}
    }

    setmetatable(instance, {__index = ModulaCore})

    instance:setupGlobals(system, library, player, construct, unit)
    instance:setupHandlers()
    instance:registerModules()

    debug("Initialised Modula Core")

    return instance
end


-- ---------------------------------------------------------------------
-- Event Handlers
-- ---------------------------------------------------------------------

function ModulaCore:setupHandlers()
    self._handlers = {
        onStart = { self },
        onStop = {},
        onActionStart = {},
        onActionLoop = {},
        onActionStop = {},
        onUpdate = {},
        onFlush = {},
        onInput = {}
    }
end

function ModulaCore:call(handler, ...)
    local objects = self._handlers[handler]
    if not objects then
        return
    end

    for i,o in pairs(objects) do
        print("calling %s on %s", handler, o.class)
        local func = o[handler]
        local status, failure = pcall(func, o, ...)
        if not status then
            failure = failure:gsub('"%-%- |STDERROR%-EVENTHANDLER[^"]*"','chunk'):
            print(failure)
            fail(failure)
            return failure
        end
    end
end

function ModulaCore:registerForEvents(handlers, object)
    for i,handler in ipairs(handlers) do
        debug("Registering %s for event %s", object.name, handler)

        if not object[handler] then
            warning("Module %s does not have a handler for %s", object.name, handler)
        else
            local registered = self._handlers[handler]
            if registered then
                table.insert(registered, object)
            else
                handlers[handler] = { object }
            end
        end
    end
end

function ModulaCore:onStart()
    self:loadElements()
end

-- ---------------------------------------------------------------------
-- Modules
-- ---------------------------------------------------------------------

function ModulaCore:registerModules()
    for module, parameters in pairs(self._modules or {}) do
        self:registerModule(module, parameters)
    end
end

function ModulaCore:registerModule(name, parameters)
    local prototype = self:loadModule(name)
    if prototype then
        debug("Registering module: %s", name)
        local module = {}
        setmetatable(module, { __index = prototype })

        table.insert(self._modules, module)
        table.insert(self._moduleNames, name)
        self._moduleIndex[name] = module

        module:register(self, parameters)
    else
        warning("Can't find module %s", name)
    end
    return module
end

function ModulaCore:loadModule(name)
    local module

    if not self._skipLocal then
        local loaderName = name:gsub("[.]", "_")
        local loader = _G[string.format("MODULE_%s", loaderName)]
        module = loader()
    end

    if not module then module = require(string.format(name)) end

    module.name = name
    return module
end

-- ---------------------------------------------------------------------
-- Elements
-- ---------------------------------------------------------------------

function ModulaCore:loadElements()
    local all = self:allElements()
    local elements = self:categoriseElements(all)
    local cores = elements.CoreUnitStatic or elements.CoreUnitDynamic or
                      elements.CoreUnitSpace
    if cores and (#cores > 0) then
        self._core = cores[1]
    else
        error("Core not found. Need to link the core to the controller.")
    end

    self._elements = elements
    self._settings = self:findElement("DataBankUnit")

    local core = self._core
    self:withElements("ScreenUnit", function(element)
        local id = element.getId()
        if core.getElementNameById(id) == "Console" then
            debug("Installed console.")
            self._console = element
        end
    end)
end

function ModulaCore:allElements()
    local elements = {}
    for k, v in pairs(_G) do
        if (k:find("Unit_") == 1) and (v.getElementClass) then
            table.insert(elements, v)
        end
    end
    return elements
end

function ModulaCore:categoriseElements(elements)
    local categorised = {}
    for i, element in ipairs(elements) do
        local class = element.getClass()
        local classElements = categorised[class]
        if not classElements then
            classElements = {}
            categorised[class] = classElements
        end

        table.insert(classElements, element)
    end

    if self._logElements then
        for k, v in pairs(categorised) do debug("Found %s %s.", #v, k) end
    end

    categorised.all = elements
    return categorised
end

function ModulaCore:findElement(category, action)
    local list = self._elements[category]
    if list then
        local element = list[1]
        if action then action(element) end
        return element
    end
end

function ModulaCore:withElements(category, action)
    local elements = self._elements[category]
    if elements then
        for i, element in ipairs(elements) do action(element, i) end
    end
end

-- ---------------------------------------------------------------------
-- Internal
-- ---------------------------------------------------------------------

function ModulaCore:setupGlobals(system, library, player, construct, unit)
    _G.system = _G.system or system
    _G.unit = _G.unit or unit
    _G.library = _G.library or library
    _G.player = _G.player or player
    _G.construct = _G.construct or construct

    _G.toString = function(item)
        if type(item) == "table" then
            local text = {}
            for k, v in pairs(item) do
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
            for i, a in ipairs({...}) do system.print(toString(a)) end
        end
    end

    if self._logging then
        _G.debug = _G.print
    else
        _G.debug = function(format, ...) end
    end

    _G.log = function(format, ...)
        local message = format:format(...)
        system.logInfo(string.format("§±%s±§", message))
    end

    _G.warning = function(format, ...)
        print("WARNING: %s", format:format(...))
    end

    _G.fail = function(format, ...)
        local message = format:format(...)
        system.showScreen(1)
        system.setScreen(string.format(
                             '<div class="window" style="position: absolute; top="10vh"; left="45vw"; width="10vw"><h1 style="middle">Error</h1><span>%s</span></div>',
                             htmlEscape(message)))
    end

    _G.htmlEscape = function(item)
        return tostring(item):gsub("&", "&amp;"):gsub("<","&lt;"):gsub(">", "&gt;"):gsub("\n", "<br>")
    end
end

function ModulaCore:testPrint()
    print(1)
    print(1.24)
    print(true)
    print("test")
    print({foo = {wibble = "bar"}})

    debug("debug")
    warning("warning")
    log("logged")
    fail("failure")
end

return ModulaCore
