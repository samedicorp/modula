-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 31/10/2020.
--  All code (c) 2020 - present day, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = {}

function Module:register(modula, parameters)
    local core = modula.core
    modula:withElements("ScreenUnit", function(element)
        local id = element.getLocalId()
        if core.getElementNameById(id) == "console" then
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
        modula:registerForEvents(self, "onOutputChanged")
    end)
end

function Module:sendLine()
    local line
    if #self.consoleBuffer > 0 then
        line = self.consoleBuffer[1]
        table.remove(self.consoleBuffer, 1)
    end
    
    self.console.setScriptInput(line)
end

function Module:onOutputChanged(output)
    self:sendLine()
end

return Module