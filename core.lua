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
        name = "core",
        version = "1.0",
        construct = {
            name = settings.name or "Untitled Construct",
            version = settings.version or "Unknown"
        },
        modules = settings.modules or {},
        moduleNames = {},
        moduleIndex = {},
        actions = {},
        elements = {},
        services = {},
        state = {},
        useLocal = settings.useLocal or false,
        logging = settings.logging or false,
        logElements = settings.logElements or false,
        logCalls = settings.logCalls or false,
        logActions = settings.logActions or false,
        timers = {},
        handlers = {},
        loopRepeat = 0.6,
        longPressTime = 0.5,
        running = false
    }

    setmetatable(instance, {__index = ModulaCore})

    instance:setupGlobals(system, library, player, construct, unit)
    instance:setupHandlers()
    instance:registerModules()
    instance:registerActions(settings.actions or {})
    instance:loadElements()
    instance:addTimer("onFastUpdate", 1.0 / 30.0)
    instance:addTimer("onSlowUpdate", 1.0)

    trace("Initialised Modula Core")
    instance.running = true

    return instance
end


-- ---------------------------------------------------------------------
-- Event Handlers
-- ---------------------------------------------------------------------

function ModulaCore:setupHandlers()
    self.handlers = {
        onStart = { self },
        onStop = { self },
        onActionStart = { self },
        onActionLoop = { self },
        onActionStop = { self },
        onInput = { self },
        onCommand = { self },
        onTick = { self }
    }
end

function ModulaCore:call(handler, ...)
    local objects = self.handlers[handler]
    if not objects then
        return
    end

    for i,o in pairs(objects) do
        if self.logCalls then
            trace("calling %s on %s", handler, o.name)
        end

        local func = o[handler]
        local status, failure = pcall(func, o, ...)
        if not status then
            failure = failure:gsub('"%-%- |STDERROR%-EVENTHANDLER[^"]*"','chunk'):
            printf(failure)
            fail(failure)
            return failure
        end
    end
end

function ModulaCore:registerForEvents(handlers, object)
    for i,handler in ipairs(handlers) do
        if not object[handler] then
            warning("Module %s does not have a handler for %s", object.name, handler)
        else
            trace("Registering %s for event %s", object.name, handler)
            local registered = self.handlers[handler]
            if registered then
                table.insert(registered, object)
            else
                self.handlers[handler] = { object }
            end
        end
    end
end

function ModulaCore:onStart()
end

function ModulaCore:onStop()
    self.running = false
    self:stopTimers()
end

function ModulaCore:onInput(text)
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end

    local command = words[1]
    table.remove(words, 1)
    self:call("onCommand", command, words)
end

function ModulaCore:onCommand(command, arguments)
    if command == "version" then
        printf("%s Version %s (core %s)", self.construct.name, self.construct.version, self.version)
    end
end

function ModulaCore:onActionStart(action)
    self:dispatchAction(action, "start")
end

function ModulaCore:onActionStop(action)
    self:dispatchAction(action, "stop")
end

function ModulaCore:onActionLoop(action)
    self:dispatchAction(action, "loop")
end

function ModulaCore:onTick(timer)
    self:call(timer)
end

-- ---------------------------------------------------------------------
-- Timers
-- ---------------------------------------------------------------------

function ModulaCore:addTimer(name, rate)
    table.insert(self.timers, name)
    unit.setTimer(name, rate)
end

function ModulaCore:stopTimers()
    for _,name in ipairs(self.timers) do
        unit.stopTimer(name)
    end
end

-- ---------------------------------------------------------------------
-- Services
-- ---------------------------------------------------------------------

function ModulaCore:registerService(name, module)
    trace("Registered %s as service %s", module.name, name)
    self.services[name] = module
end

function ModulaCore:getService(name)
    return self.services[name]
end

-- ---------------------------------------------------------------------
-- Modules
-- ---------------------------------------------------------------------

function ModulaCore:registerModules()
    local modules = self.modules or {}
    self.modules = {}
    for module, parameters in pairs(modules) do
        self:registerModule(module, parameters)
    end
end

function ModulaCore:registerModule(name, parameters)
    local prototype = self:loadModule(name)
    if prototype then
        trace("Registering module: %s", name)
        local module = { modula = self }
        setmetatable(module, { __index = prototype })

        table.insert(self.modules, module)
        table.insert(self.moduleNames, name)
        self.moduleIndex[name] = module

        module:register(self, parameters)
    else
        warning("Can't find module %s", name)
    end
end

function ModulaCore:loadModule(name)
    local module

    if self.useLocal then 
        -- prefer local source version if it is present
        module = require(name) 
    end

    if module then
        trace("Using local module %s", name)
    else
        -- try to load module from version stashed in library.onStart
        local loaderName = name:gsub("[.-]", "_")
        local loader = _G[string.format("MODULE_%s", loaderName)]
        module = loader()
    end

    if module then
        module.name = name
    end

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
        self.core = cores[1]
    else
        warning("Core not found. Need to link the core to the controller.")
    end

    self.elements = elements
    self.settings = self:findElement("DataBankUnit")

    local core = self.core
    self:withElements("ScreenUnit", function(element)
        local id = element.getId()
        if core.getElementNameById(id) == "Console" then
            trace("Installed console.")
            self.console = element
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

    if self.logElements then
        for k, v in pairs(categorised) do trace("Found %s %s.", #v, k) end
    end

    categorised.all = elements
    return categorised
end

function ModulaCore:findElement(category, action)
    local list = self.elements[category]
    if list then
        local element = list[1]
        if action then action(element) end
        return element
    end
end

function ModulaCore:withElements(category, action)
    local elements = self.elements[category]
    if elements then
        for i, element in ipairs(elements) do action(element, i) end
    end
end


-- ---------------------------------------------------------------------
-- Input
-- ---------------------------------------------------------------------

function ModulaCore:registerActions(config)
    for k,entry in pairs(config) do
        entry.start = entry.start or entry.loop or entry.onoff or entry.all
        entry.loop = entry.loop or entry.all
        entry.stop = entry.stop or entry.onoff or entry.all
        entry.startTime = 0
        entry.loopTime = 0
        entry.module = self.services[entry.target]
        if entry.module then
            self:checkActionHandlers(entry.module, entry.start, entry.stop, entry.loop, entry.long)
        else
            warning("No service %s is registered for action %s", entry.target, k)
        end
    end
    self.actions = config
end

function ModulaCore:checkActionHandlers(module, ...)
    for i,handler in ipairs({ ... }) do
        if handler and not module[handler] then
            warning("Module %s does not have an action handler %s", module.name, handler)
        end
    end
end

function ModulaCore:dispatchAction(action, mode)
    local entry = self.actions[action]
    if entry then
        local module = entry.module
        if module then
            local handler = entry[mode]
            local time = system.getArkTime()
            if mode == "start" then
                entry.startTime = time
                entry.loopTime = time
                entry.longDone = false

            elseif mode == "loop" then
                if entry.longDone then
                    return
                end

                local elapsed = (time - entry.startTime)
                if entry.long and (elapsed > self.longPressTime) then
                    -- do the long press if enough time has elapsed
                    handler = entry.long
                    entry.longDone = true
                
                elseif (time - entry.loopTime) < self.loopRepeat then
                    -- if not enough time has passed yet, skip this loop iteration
                    return
                end

                entry.loopTime = time

            else
                if entry.long and entry.longDone then
                    -- skip the stop action if the long press has been done
                    return
                end
            end

            if handler then
                local func = module[handler]
                if func then
                    local status, error = pcall(func, module, mode, entry.arg, action)
                    if not status then
                        trace("%s %s crashed: %s %s %s", entry.target, handler, mode, action, error)
                    end
                end
            end
        end
    end

    if self.logActions then
        trace("%s %s no handler", action, mode)
    end
end

-- ---------------------------------------------------------------------
-- Settings
-- ---------------------------------------------------------------------

function ModulaCore:gotSettings()
    return self.settings ~= nil
end

function ModulaCore:loadString(key)
    if self.settings then
        return self.settings.getStringValue(key)
    end
end

function ModulaCore:loadInt(key)
    if self.settings then
        return self.settings.getIntValue(key)
    end
end

function ModulaCore:loadBool(key)
    if self.settings then
        return self.settings.getIntValue(key) == 1
    end
end

function ModulaCore:saveString(key, value)
    if self.settings then
        self.settings.setStringValue(key, value)
    end
end

function ModulaCore:saveInt(key, value)
    if self.settings then
        self.settings.setIntValue(key, value)
    end
end

function ModulaCore:saveBool(key, value)
    if self.settings then
        if value then
            value = 1
        else
            value = 0
        end
        self.settings.setIntValue(key, value)
    end
end

-- ---------------------------------------------------------------------
-- Global Helpers
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

    _G.printf = function(format, ...)
        local t = type(format)

        if type(format) == "string" then
            system.print(format:format(...))
        else
            system.print(toString(format))
            for i, a in ipairs({...}) do system.print(toString(a)) end
        end
    end

    if self.logging then
        _G.trace = printf
    else
        _G.trace = function(format, ...) end
    end

    _G.log = function(format, ...)
        local message = format:format(...)
        system.logInfo(string.format("§±%s±§", message))
    end

    _G.warning = function(format, ...)
        printf("WARNING: %s", format:format(...))
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

return ModulaCore
