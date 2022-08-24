-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 31/10/2020.
--  All code (c) 2020 - present day, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = {}

function Module:register(modula, parameters)
    modula:registerForEvents(self, "onOutputChanged", "onSlowUpdate")

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
            self.consoleBuffer = {}
            self.sysPrint = modula.rawPrint
            modula.rawPrint = function(text)
                self.sysPrint(text)
                table.insert(self.consoleBuffer, text)
            end
            element.setRenderScript([[
                local render = require('samedicorp.modula.render')
                local input = getInput()
                frame = frame or 0
                buffer = buffer or {}
                if input then
                    table.insert(buffer, input)
                end
                render:textLineField(buffer, render:safeRect(), "Play", 20)
                setOutput(frame)
                frame = frame + 1
            ]])
        end
            
        debugf("Installed console.")
    end)
end

function Module:sendLine()
    local count = #self.consoleBuffer
    if count > 0 then
        if not self.sending then
            self.sending = true
            local line = self.consoleBuffer[1]
            table.remove(self.consoleBuffer, 1)
            self.console.setScriptInput(line)
        end
    end
end

function Module:onSlowUpdate()
    self:sendLine()
end

function Module:onOutputChanged(output)
    if #self.consoleBuffer == 0 then
        self.console.setScriptInput(nil)
    end
    self.sending = false
    self:sendLine()
end

return Module