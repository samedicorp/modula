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
-- 
-- Note that this deliberately does not use the screen module, but instead
-- implements similar code. This is intentional as it allows the console to
-- be used to debug the screen module.

local Module = {}

function Module:register(parameters)
    modula:registerForEvents(self, "onConsoleOutput", "onSlowUpdate")

    self.buffer = {}
    local name = parameters.name
    if name then
        self:connectTo(name)
    end
end

function Module:connectTo(name)
    modula:withElements("ScreenUnit", function(element)
        if element:name() == name then
            self.console = element.element
            self.sysPrint = modula.rawPrint
            modula.rawPrint = function(text)
                self.sysPrint(text)
                table.insert(self.buffer, text)
            end

            local toolkit
            if modula.useLocal then
                toolkit = "require('samedicorp.toolkit.toolkit')"
            else
                toolkit = TOOLKIT_SOURCE()
            end
            element.element.setRenderScript(self.renderScript:format(toolkit))

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

Module.renderScript = [[
    %s

    local screen = toolkit.Screen.new() 
    frame = frame or 0
    buffer = buffer or {}
    local input = getInput()
    if input then
        table.insert(buffer, input)
    end

    local layer = screen:addLayer()
    layer:textLineField(buffer, screen:safeRect())

    frame = frame + 1
    if input then
        setOutput(frame)
    end
]]

return Module