-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 20/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local json = require('dkjson')

local Module = {}
local Screen = {}

function Module:register(parameters)
    self.screens = {}
    self.logIO = parameters.logIO or false

    modula:registerForEvents(self, "onScreenReply", "onSlowUpdate")
    modula:registerService(self, "screen")
end

-- ---------------------------------------------------------------------
-- Example event handlers
-- ---------------------------------------------------------------------

function Module:registerScreen(handler, name, script)
    local core = modula.core
    local registered
    modula:withElements("ScreenUnit", function(element)
        local screenName = element:name()
        if (not name) or (screenName == name) then
            local screen = {
                name = screenName,
                element = element,
                buffer = {},
                handler = handler,
                logIO = self.logIO
            }
            setmetatable(screen, { __index = Screen })
            self.screens[screenName] = screen

            local du = element.element
            du.setScriptInput(nil)
            local toolkit
            if modula.useLocal then
                toolkit = string.format([[

                if not toolkit then
                    require('samedicorp.toolkit.toolkit')
                    screen = require('%s')
                end

                ]], script)
            else
                toolkit = string.format([[
                    %s

                    %s

                    if frame == 1 then
                        screen = SCREEN_%s()
                    end

                ]], TOOLKIT_SOURCE(), SCREEN_SOURCE(), screenName)
            end
            du.setRenderScript(self.renderScript:format(screenName, toolkit))
            debugf("Registered screen %s.", screenName)
            registered = screen
            return true
        end
    end)

    return registered
end

function Module:onSlowUpdate()
    for name, screen in pairs(self.screens) do
        screen:flush()
    end
end

function Module:onScreenReply(output)
    local decoded = json.decode(output)
    if decoded then
        local screen = self.screens[decoded.target]
        if screen then
            screen:onReply(decoded.payload)
            if self.logIO then
                debugf("receive: %s", output)
            end
            return
        end
    end

    if self.logIO then
        debugf("receive not handled: %s", output)
    end
end

function Module:useLocalToolkit()
    if modula.useLocal then
        local status, result = pcall(require, 'samedicorp.toolkit.installed')
        if status then
            return result
        end
    end

    return false
end

Module.renderScript = [[
    local json = require('dkjson')
    frame = (frame or 0) + 1
    local name = '%s'
    local payload

    local input = getInput()
    if input then
        payload = json.decode(input)
    end

    %s

    local reply = screen:render(payload, toolkit)
    if reply then
        local payload = { target = name, payload = reply }
        local status, result = pcall(json.encode, payload)
        if status then
            local escaped = result:gsub("\"", "\\\"")
            setOutput(escaped)
        else
            logMessage("error")
            logMessage(result)
            setOutput(result)
        end
    end
]]

function Screen:send(message)
    local encoded = json.encode(message)
    table.insert(self.buffer, encoded)
end

function Screen:flush()
    local count = #self.buffer
    if count > 0 then
        if not self.sending then
            self.sending = true
            local payload = self.buffer[1]
            table.remove(self.buffer, 1)
            self.element.element.setScriptInput(payload)
            if self.logIO then
                debugf("send: %s", payload)
            end
        end
    end
end

function Screen:onReply(reply)
    if self.handler then
        self.handler:onScreenReply(reply)
        if #self.buffer == 0 then
            self.element.element.setScriptInput(nil)
            self.element.element.clearScriptOutput()
        end
        self.sending = false
        self:flush()
    end
end

return Module
