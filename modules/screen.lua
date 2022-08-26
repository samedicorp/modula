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

function Module:registerScreen(handler, name)
    local modula = self.modula
    local core = modula.core
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
            local script = [[
                local render = require('samedicorp.modula.render')
                local input = getInput()
                local name = '%s'
                frame = frame or 0

                local font = loadFont("Play", 20)
                local layer = createLayer()
                addText(layer, font, name, 10, 20)
                addText(layer, font, input, 10, 40)
                setOutput(name .. ":done")
            ]]

            element.setRenderScript(script:format(name))
            debugf("Registered screen %s.", name)

            return screen
        end
    end)
end

function Module:onSlowUpdate()
    if not self.sending then
        for i,screen in ipairs(self.screens) do
            screen:flush()
        end
    end
end

function Module:onScreenReply(output)
    local i = output:find(":")
    if i then
        local name = output:sub(1, i - 1)
        local reply = output:sub(i + 1)
        local screen = self.screens[name]
        if screen then
            screen.handler:onScreenReply(reply)
        end
    end
end


function Screen:send(command)
    table.insert(self.buffer, command)
end

function Screen:flush()
    local count = #self.buffer
    if count > 0 then
        if not self.sending then
            self.sending = true
            local line = self.buffer[1]
            table.remove(self.buffer, 1)
            self.element.setScriptInput(line)
            system.print("Sent command: " .. line)
        end
    end
end

return Module