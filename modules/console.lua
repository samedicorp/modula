-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 31/10/2020.
--  All code (c) 2020 - present day, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- If a screen with the right name is linked, we use it as a console and
-- echo all printf/debugf output to it.
--
-- For this to work, you need to add an onOutputChanged handler to the screen
-- containing the following:
--
--   local failure = modula:call("onConsoleOutput", output)
--   if failure then 
--     error(failure) 
--   end

local Module = {}

function Module:register(modula, parameters)
    modula:registerForEvents(self, "onConsoleOutput", "onSlowUpdate")

    local name = parameters.name
    if name then
        self:connectTo(modula, name)
    end
end

function Module:connectTo(modula, name)
    local core = modula.core
    modula:withElements("ScreenUnit", function(element)
        local id = element.getLocalId()
        if core.getElementNameById(id) == name then
            self.console = element
            self.buffer = {}
            self.sysPrint = modula.rawPrint
            modula.rawPrint = function(text)
                self.sysPrint(text)
                table.insert(self.buffer, text)
            end
            element.setRenderScript([[
                local render = require('samedicorp.modula.render')
                frame = frame or 0
                buffer = buffer or {}
                local input = getInput()
                if input then
                    table.insert(buffer, input)
                end
                render:textLineField(buffer, render:safeRect(), "Play", 20)

                frame = frame + 1
                if input then
                    setOutput(frame)
                end
            ]])

            debugf("Installed console.")
        end
            
    end)
end

function Module:flushBuffer()
    local count = #self.buffer
    if count > 0 then
        if not self.sending then
            self.sending = true
            local line = self.buffer[1]
            table.remove(self.buffer, 1)
            self.console.setScriptInput(line)
        end
    end
end

function Module:onSlowUpdate()
    if not self.sending then
        self:flushBuffer()
    end
end

function Module:onConsoleOutput(output)
    if #self.buffer == 0 then
        self.console.setScriptInput(nil)
    end
    self.sending = false
    self:flushBuffer()
end

return Module