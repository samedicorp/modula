-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 20/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-



local Module = { }
local Screen = { }

function Module:register(modula, parameters)
    self.screens = {}

    modula:registerForEvents(self, "onScreenReply", "onSlowUpdate")
    modula:registerService(self, "screen")
end

-- ---------------------------------------------------------------------
-- Example event handlers
-- ---------------------------------------------------------------------

function Module:registerScreen(handler, name, code)
    local modula = self.modula
    local core = modula.core
    local registered
    modula:withElements("ScreenUnit", function(element)
        local id = element.getLocalId()
        if core.getElementNameById(id) == name then
            local screen = {
                name = name,
                element = element,
                buffer = {},
                handler = handler
            }
            setmetatable(screen, { __index = Screen })
            self.screens[name] = screen
            

            element.setScriptInput(nil)
            element.setRenderScript(self.renderScript:format(name, code))
            debugf("Registered screen %s.", name)
            registered = screen
            return screen
        end
    end)

    return registered
end

function Module:onSlowUpdate()
    for name,screen in pairs(self.screens) do
        screen:flush()
    end
end

function Module:onScreenReply(output)
    local i = output:find(":")
    if i then
        local name = output:sub(1, i - 1)
        local reply = output:sub(i + 1)
        local screen = self.screens[name]
        if screen then
            screen:onReply(reply)
        end
    end
end

Module.renderScript = [[
    frame = frame or 0
    local render = require('samedicorp.modula.render')
    local name = '%s'
    local reply
    local input = getInput()
    local command
    local payload
    
    if input then
        local i = input:find(":")
        if i then
            command = input:sub(1, i - 1)
            payload = input:sub(i + 1)
        end
    end
    
    %s
    
    if reply then
        setOutput(string.format("%%s:%%s", name, reply))
    end
]]

function Screen:send(command, payload)
    printf("send: %s %s", command, payload)
    table.insert(self.buffer, string.format("%s:%s", command, payload or ""))
end

function Screen:flush()
    local count = #self.buffer
    if count > 0 then
        printf("flush %s", self.name)
        if not self.sending then
            self.sending = true
            local line = self.buffer[1]
            table.remove(self.buffer, 1)
            self.element.setScriptInput(line)
            system.print("Sent command: " .. line)
        end
    end
end

function Screen:onReply(reply)
    if self.handler then
        self.handler:onScreenReply(reply)
        if #self.buffer == 0 then
            self.element.setScriptInput(nil)
        end
        self.sending = false
        self:flush()
    end
end


return Module