-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 31/10/2020.
--  All code (c) 2020 - present day, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = {}

function Module:register(modula, parameters)
    modula:registerForEvents({"onStart", "onStop", "onFastUpdate"}, self)
    modula:registerService("screen", self)

    self.screen = ""
    self.screenDirty = true
    self.windows = {}
    self.frame = 0
    self.html = ""
end

function Module:onStart()
    self.html = [[<style>
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

    system.showScreen(1)

    trace("Screen manager running.")
end

function Module:onStop()
    system.showScreen(0)
    trace("Display manager stopped.")
end

function Module:onFastUpdate()
    -- local flight = self.flight
    -- local controller = self.controller
    -- local core = controller:getCore()

   -- self.modula:call("onDisplayUpdate", self)
    -- -- self:updateMenus()

    -- -- self.frame = self.frame + 1

    -- if self.screenDirty then
    --     -- debug("%s built screen", self.frame)
    --     self:buildScreen()
    --     if self.screen ~= self.currentScreen then
    --         self.currentScreen = self.screen
    --         system.setScreen(self.screen)
    --     else
    --         debug("%s no change after screen rebuild", self.frame)
    --     end
    --     self.screenDirty = false
    -- end
end

-- function Module:addWindow(window)
--     table.insert(self.windows, window)
--     self.screenDirty = true
-- end

-- function Module:updateWindow(window, content)
--     local old = window.content
--     window.content = content
--     local contentChanged = content ~= old
--     if contentChanged then
--         -- debug("%s window %s content changed", self.frame, window.name)
--     end
--     self.screenDirty = self.screenDirty or contentChanged
-- end

-- function Module:buildScreen()
 
--     local html = { self.html }

--     for i,window in ipairs(self.windows) do
--         local style = {}
--         for k,v in pairs(window) do
--             if (k ~= "content") and (k ~= "name") and (k ~= "html")and (k ~= "style") then
--                 table.insert(style, string.format("%s: %s", k, v))
--             end
--         end

--         table.insert(html, string.format('<div class="samedi-window" style="%s">%s</div>', table.concat(style, ";"), window.content))
--     end

--     self.screen = table.concat(html, "\n")
-- end

return Module