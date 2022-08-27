-- -=screen.lua=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 31/10/2020.
--  All code (c) 2020 - present day, The Samedi Corporation.
-- -=screen.lua=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = {}
local Window = {}

function Module:register(parameters)
    modula:registerForEvents(self, "onStart", "onStop", "onFastUpdate")
    modula:registerService(self, "windows")

    self.screen = ""
    self.screenDirty = true
    self.windows = {}
    self.frame = 0
    self.logChanges = parameters.logChanges or false
    self:setHeader()
end

function Module:setHeader()
    self.header = [[<style>
    :root {
        --primary-color: #7fff00;
        --standout-color: white;
        --primary-width: 3px;
        --green-light: #7fff00;
        --red-light: red;
        --ok-color: #7fff00;
        --warning-color: orange;
        --alert-color: red;
        --on-color: yellow;
        --off-color: black;
    }
    .samedi-window {
        font-family: Arial, Helvetica, sans-serif; font-size: 2vw;;
        /*text-shadow: 0 0 5px #fff, 0 0 10px #fff, 0 0 15px #0073e6, 0 0 20px #0073e6, 0 0 25px #0073e6, 0 0 30px #0073e6, 0 0 35px #0073e6;*/
        padding: 0px;
      }
    .small-label { font-size: 1.8vw; }
    .mark   { stroke: var(--primary-color); stroke-width: var(--primary-width); }
    .margin   { stroke: var(--primary-color); stroke-width: var(--primary-width)px; }
    .box { fill: black; stroke: white; stroke-width: 2; }
    .label  { fill: var(--primary-color); text-anchor: end; alignment-baseline: central; }
    .value { fill: var(--standout-color); text-anchor: start; alignment-baseline: central; }
    </style>
    ]]
end

function Module:onStart()
    system.showScreen(1)
    debugf("Window manager running.")
end

function Module:onStop()
    system.showScreen(0)
    debugf("Window manager stopped.")
end

function Module:onFastUpdate()
   modula:call("onUpdateWindows", self)

   local loggingEnabled = self.logChanges
   if loggingEnabled then
       self.frame = self.frame + 1
   end

    if self.screenDirty then
        if loggingEnabled then
            debugf("%s built screen", self.frame)
        end

        self:buildScreen()
        if self.screen ~= self.currentScreen then
            self.currentScreen = self.screen
            system.setScreen(self.screen)
        elseif loggingEnabled then
            debug("%s no change after screen rebuild", self.frame)
        end
        self.screenDirty = false
    end
end

function Module:addWindow(window)
    setmetatable(window, { __index = Window })
    window.data = { screen = self, style = "", content = "", div = "", name = window.name or "Untitled" }
    window.name = nil
    table.insert(self.windows, window)
    self.screenDirty = true
end

function Module:buildScreen()
    local html = { self.header }

    for i,window in ipairs(self.windows) do
        local data = window.data
        table.insert(html, data.div)
    end

    self.screen = table.concat(html, "\n")
end

function Window:update(content)
    local data = self.data
    local screen = data.screen

    local contentChanged = content ~= data.content
    if contentChanged then
        -- rebuild css properties
        local properties = {}
        for k,v in pairs(self) do
            if (k ~= "data") then
                table.insert(properties, string.format("%s: %s", k, v))
            end
        end

        -- rebuild window <div> tag
        data.div = string.format('<div class="samedi-window" style="%s">%s</div>', table.concat(properties, ";"), content)
        data.content = content
        screen.screenDirty = true
        if screen.logChanges then
            debugf("%s window %s content changed", screen.frame, data.name)
        end
    end
end

return Module