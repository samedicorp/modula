-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 25/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

ModulaCore = {
    class = "ModulaCore"
}

function ModulaCore.new(system, library, player, construct, unit, settings)
    system.print(string.format("Initialising Modula Core. Lua version %s", _VERSION))
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
        logRegistrations = settings.logRegistrations or false,
        timers = {},
        handlers = {},
        loopRepeat = 0.6,
        longPressTime = 0.5,
        running = false,
        rawPrint = system.print
    }

    setmetatable(instance, { __index = ModulaCore })

    instance:setupGlobals(system, library, player, construct, unit)
    instance:setupHandlers()
    instance:loadElements()
    instance:registerModules()
    instance:registerActions(settings.actions or {})

    debugf("Initialised Modula Core.")
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

    for i, o in pairs(objects) do
        if self.logCalls then
            debugf("calling %s on %s", handler, o.name)
        end

        local func = o[handler]
        local status, failure = pcall(func, o, ...)
        if not status then
            local pattern = '"[string'
            local message = string.gsub(failure, '.*:.*:(.*)', "%1")
            local line = string.gsub(failure, '.*:(.*):.*', "%1")
            -- printf("ERROR in %s.%s, %s", o.name, handler, line)
            -- printf(message)
            -- printf(traceback())
            -- failure = failure:gsub('%[string "%-%- %-%=(%w+).*%]', "%1")
            -- failure = failure:gsub('%[string "%-%- %-%=', "")
            -- failure = failure:gsub('"%-%- |STDERROR%-EVENTHANDLER[^"]*"','chunk'):
            failure = string.format("%s:%s: %s in %s\n\n%s", o.name, line, message, handler, traceback())
            fail(failure)
            return failure
        end
    end
end

function ModulaCore:callx(handler, ...)
    local objects = self.handlers[handler]
    if not objects then
        return
    end

    for i, o in pairs(objects) do
        if self.logCalls then
            debugf("calling %s on %s", handler, o.name)
        end

        local func = o[handler]
        local errHandler = function(failure)
            local pattern = '"[string'
            local message = string.gsub(failure, '.*:.*:(.*)', "%1")
            local line = string.gsub(failure, '.*:(.*):.*', "%1")
            -- printf("ERROR in %s.%s, %s", o.name, handler, line)
            -- printf(message)
            -- printf(traceback())
            -- failure = failure:gsub('%[string "%-%- %-%=(%w+).*%]', "%1")
            -- failure = failure:gsub('%[string "%-%- %-%=', "")
            -- failure = failure:gsub('"%-%- |STDERROR%-EVENTHANDLER[^"]*"','chunk'):
            failure = string.format("%s:%s: %s in %s\n\n%s", o.name, line, message, handler, traceback())
            fail(failure)
            return failure
        end

        local status, result = xpcall(o[handler], errHandler, o, ...)
        return result

        -- if not status then
        --     fail(error)
        --     return error

        --     -- local pattern = '"[strin'
        --     -- local message = string.gsub(failure, '.*:.*:(.*)', "%1")
        --     -- local line = string.gsub(failure, '.*:(.*):.*', "%1")
        --     -- -- printf("ERROR in %s.%s, %s", o.name, handler, line)
        --     -- -- printf(message)
        --     -- -- printf(traceback())
        --     -- -- failure = failure:gsub('%[string "%-%- %-%=(%w+).*%]', "%1")
        --     -- -- failure = failure:gsub('%[string "%-%- %-%=', "")
        --     -- -- failure = failure:gsub('"%-%- |STDERROR%-EVENTHANDLER[^"]*"','chunk'):
        --     -- failure = string.format("%s:%s: %s in %s", o.name, line, message, handler)
        --     -- fail(string.format("%s:%s: %s\nin %s\n\n%s", o.name, line, message, handler, traceback()))
        --     -- return failure
        -- end
    end
end

function ModulaCore:registerForEvents(object, ...)
    local handlers = { ... }
    for i, handler in ipairs(handlers) do
        if not object[handler] then
            warning("Module %s does not have a handler for %s", object.name, handler)
        else
            if self.logRegistrations then
                debugf("Registering %s for event %s", object.name, handler)
            end
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
    self:addTimer("onFastUpdate", 1.0 / 30.0)
    self:addTimer("onSlowUpdate", 1.0)
end

function ModulaCore:onStop()
    self.stopping = true
    self:stopTimers()
    self:call("onStopping")
    self.running = false
    self.stopping = false
    debugf("Shut down Modula Core.")
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
    for _, name in ipairs(self.timers) do
        unit.stopTimer(name)
    end
end

-- ---------------------------------------------------------------------
-- Services
-- ---------------------------------------------------------------------

function ModulaCore:registerService(module, name)
    if self.logRegistrations then
        debugf("Registered %s as service %s", module.name, name)
    end
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
        if self.logRegistrations then
            debugf("Registering module: %s", name)
        end
        local module = {}
        setmetatable(module, { __index = prototype })

        table.insert(self.modules, module)
        table.insert(self.moduleNames, name)
        self.moduleIndex[name] = module

        -- TODO: proper error handling here
        local status, failure = pcall(module.register, module, parameters)
        if not status then
            printf(failure)
        end
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
        debugf("Using local module %s", name)
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

Element = {}

function ModulaCore:subclassElement(subclass)
    setmetatable(subclass, { __index = Element })
end

function Element:name()
    return self.element.getName()
end

function Element:simpleName()
    return self:simplifyName(self.element.getName())
end

function Element:simplifyName(name)
    local removeWords = { "Basic", "Uncommon", "Industry", "Product", "Pure" }
    for _, word in ipairs(removeWords) do
        name = name:gsub(word, "")
    end
    return name
end

function Element:label()
    return self.core.getElementDisplayNameById(self.id)
end

function Element:simpleLabel()
    return self:simplifyName(self.core.getElementDisplayNameById(self.id))
end

function ModulaCore:loadElements()
    local all = self:allElements()
    local categorised = self:categoriseElements(all)
    local cores = categorised.CoreUnitStatic or categorised.CoreUnitDynamic or
        categorised.CoreUnitSpace
    if cores and (#cores > 0) then
        local core = cores[1]
        self.core = core
        self.elements = self:makeElementObjects(categorised, core)
    else
        warning("Core not found. Need to link the core to the controller.")
        self.elements = {}
    end

    self.settings = self:findElement("DataBankUnit")
end

function ModulaCore:makeElementObjects(index, core)
    local result = {}
    local all = {}
    for category, elements in pairs(index) do
        local objects = {}
        for i, element in ipairs(elements) do
            local object = {
                element = element, -- TODO: deprecate this
                object = element,
                id = element.getLocalId(),
                core = core,
                kind = element.getItemId()
            }
            setmetatable(object, { __index = Element })
            table.insert(objects, object)
            table.insert(all, object)
        end
        result[category] = objects
        if self.logElements then
            local names = {}
            for i, object in ipairs(objects) do
                table.insert(names, object:name())
            end
            debugf("Found %s %s: %s.", #objects, category, table.concat(names, ","))
        end
    end

    result.all = all
    return result
end

function ModulaCore:allElements()
    local elements = {}
    for k, v in pairs(_G) do
        if (k:find("Unit_") == 1) and (v.getElementClass) then
            v.hideWidget()
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
        for i, element in ipairs(elements) do
            if action(element, i) then
                break
            end
        end
    end
end

-- ---------------------------------------------------------------------
-- Input
-- ---------------------------------------------------------------------

function ModulaCore:registerActions(config)
    for k, entry in pairs(config) do
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
    for i, handler in ipairs({ ... }) do
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
                        debugf("%s %s crashed: %s %s %s", entry.target, handler, mode, action, error)
                    end
                end
            end
        end
    end

    if self.logActions then
        debugf("%s %s no handler", action, mode)
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
    _G.modula = self

    _G.toString = function(item, visited)
        local t = type(item)
        if t == "table" then
            visited = visited or {}
            local text = {}
            for k, v in pairs(item) do
                local string = visited[v]
                if not string then
                    visited[v] = "<recursion>"
                    string = toString(v, visited)
                    visited[v] = string
                end
                table.insert(text, string.format("%s: %s", k, string))
            end
            return "{ " .. table.concat(text, ", ") .. " }"
        elseif t == "function" then
            return "()"
        else
            return tostring(item, visited)
        end
    end

    _G.printf = function(format, ...)
        local t = type(format)

        local rawPrint = self.rawPrint
        if type(format) == "string" then
            rawPrint(format:format(...))
        else
            rawPrint(toString(format))
            for i, a in ipairs({ ... }) do rawPrint(toString(a)) end
        end
    end

    if self.logging then
        _G.debugf = printf
    else
        _G.debugf = function(format, ...) end
    end

    _G.log = function(format, ...)
        local message = format:format(...)
        system.logInfo(string.format("§±%s±§", message))
    end

    _G.warning = function(format, ...)
        printf("WARNING: %s", format:format(...))
    end

    _G.fail = function(format, ...)
        self:stopTimers()
        self.running = false

        local message = format:format(...)
        system.print(message)
        system.showScreen(1)
        system.setScreen(string.format(
            '<div class="window" style="position: absolute; top="10vh"; left="45vw"; width="10vw"><h1 style="middle">Error</h1><span>%s</span></div>',
            htmlEscape(message)))
    end

    _G.htmlEscape = function(item)
        return tostring(item):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\n", "<br>")
    end
end

return ModulaCore
