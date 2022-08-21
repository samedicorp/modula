-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 31/10/2020.
--  All code (c) 2020 - present day, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = {}

function Module:register(modula, parameters)
    modula:registerForEvents({"onStart", "onStop", "onFastUpdate"}, self)
    modula:registerService("display", self)

    self.widgetRecords = {}
    self.panels = {}
    self.screen = ""
    self.screenDirty = true
    self.windows = {}
    self.frame = 0
    self.html = ""
end

function Module:onStart()
    debug("Display module started.")

    self:addPanel("default", "Display", true)
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

    debug("Display manager running.")
end

function Module:onStop()
    system.showScreen(0)

    for name,widget in pairs(self.widgetRecords) do
        if widget.id then
            system.destroyWidget(widget.id)
        end
        system.destroyData(widget.data)
    end

    system.destroyWidgetPanel(self.panel)

    self.widgetRecords = {}
    self.datas = {}
    self.panel = nil
end

function Module:onFastUpdate()
    -- local flight = self.flight
    -- local controller = self.controller
    -- local core = controller:getCore()

    self.modula:call("onDisplayUpdate", self)
    -- self:updateMenus()

    -- self.frame = self.frame + 1

    if self.screenDirty then
        -- debug("%s built screen", self.frame)
        self:buildScreen()
        if self.screen ~= self.currentScreen then
            self.currentScreen = self.screen
            system.setScreen(self.screen)
        else
            debug("%s no change after screen rebuild", self.frame)
        end
        self.screenDirty = false
    end
end

function Module:addWindow(window)
    table.insert(self.windows, window)
    self.screenDirty = true
end

function Module:updateWindow(window, content)
    local old = window.content
    window.content = content
    local contentChanged = content ~= old
    if contentChanged then
        -- debug("%s window %s content changed", self.frame, window.name)
    end
    self.screenDirty = self.screenDirty or contentChanged
end

function Module:buildScreen()
 
    local html = { self.html }

    for i,window in ipairs(self.windows) do
        local style = {}
        for k,v in pairs(window) do
            if (k ~= "content") and (k ~= "name") and (k ~= "html")and (k ~= "style") then
                table.insert(style, string.format("%s: %s", k, v))
            end
        end

        table.insert(html, string.format('<div class="samedi-window" style="%s">%s</div>', table.concat(style, ";"), window.content))
    end

    self.screen = table.concat(html, "\n")
end

function Module:panelDebug(text, ...)
        --debug(text, ...)
end

function Module:addPanel(name, title, startHidden)
    self:panelDebug("adding panel %s as %s", name, title)
    local panel = { name = name, widgets = {}, title = title }
    self.panels[name] = panel
    if not startHidden then
        self:showPanel(name)
    end
end

function Module:showPanel(name)
    self:panelDebug("show panel %s", name)
    local panel = self.panels[name]
    if not panel.id then
        panel.id = system.createWidgetPanel(panel.title)
        self:panelDebug("created panel %s id: %s", name, panel.id)
        for i,widget in ipairs(panel.widgets) do
            self:showWidget(widget)
        end
    end
end

function Module:hidePanel(name)
    local panel = self.panels[name]
    if panel.id then
        for i,widget in ipairs(panel.widgets) do
            self:hideWidget(widget)
        end
        system.destroyWidgetPanel(panel.id)
        panel.id = nil
    end
end

function Module:addWidget(name, type, panelName, data)
    self:panelDebug("adding widget %s for panel %s", name, panelName)
    local panel = self.panels[panelName]
    if not panel then
        self:panelDebug("panel %s missing - using default", panelName)
        panel = self.panels["default"]
    end

    local widget = { name = name, type = type, data = data, panel = panel }
    self:showWidget(widget)
    self.widgetRecords[name] = widget
    table.insert(panel.widgets, widget)
    return widget
end

function Module:showWidget(widget)
    self:panelDebug("showing widget %s for panel %s %s", widget.name, widget.panel.name, widget.panel.id)
    if not widget.id then
        widget.id = system.createWidget(widget.panel.id, widget.type)
        self:panelDebug("created widget %s for panel %s", widget.id, widget.panel.id)
        if widget.data then
            system.addDataToWidget(widget.data, widget.id)
        end
    end
end

function Module:hideWidget(widget)
    if widget.id then
        system.destroyWidget(widget.id)
        widget.id = nil
    end
    if widget.data then
        system.destroyData(widget.data)
        widget.data = nil
    end
end

function Module:addWidgets(panel, type, widgets)
    for i,widget in ipairs(widgets) do
            self:addWidget(widget, type, panel)
    end
end

function Module:addWidgetsT(panel, type, widgets)
    for i,widget in ipairs(widgets) do
        local record = self:addWidget(widget.name, type, panel)
        for k,v in pairs(widget) do
            record[k] = v
        end
    end
end


function Module:updateWidgetText(name, text, ...)
    local widget = self.widgetRecords[name]
    if widget then
        local json = string.format('{"text": "%s "}', string.format(text, ...))
        if not widget.data then
            widget.data = system.createData(json)
            if widget.id then
                system.addDataToWidget(widget.data, widget.id)
            end
            self:panelDebug("created text data for %s %s", name, text)
        else
            system.updateData(widget.data, json)
            self:panelDebug("updated text data for %s name %s", name, text)
        end
    else
        self:panelDebug("missing widget %s", name)
    end
end

function Module:updateWidgetValue(name, value)
    local widget = self.widgetRecords[name]
    if widget then
       local json = string.format('{"label": "%s ", "value": "%s", "unit": "%s"}', widget.label, value, widget.units)
        if not widget.data then
            widget.data = system.createData(json)
            if widget.id then
                system.addDataToWidget(widget.data, widget.id)
            end
        else
            system.updateData(widget.data, json)
        end
    else
        self:panelDebug("missing widget %s", name)
    end
end

function Module:updateWidgetFloat(name, value)
    self:updateWidgetValue(name, string.format("%.2f", value))
end

function Module:updateWidgetVector(name, value)
    self:updateWidgetValue(name, string.format("%+.1f %+.1f %+.1f", value.x, value.y, value.z))
end

function Module:time(seconds)
    local hours = math.floor(seconds / 3600)
    seconds = seconds - hours*3600
    local mins = math.floor(seconds / 60)
    seconds = math.floor(seconds - mins*60)
    if hours > 0 then
        return string.format("%sh %sm %ss", hours, mins, seconds)
    elseif mins > 0 then
        return string.format("%sm %ss", mins, seconds)
    else
        return string.format("%ss", seconds)
    end
end

function Module:setupMenus()
    self:addPanel("menu", "Options")
    self.menubar = {}
    self.menuSelection = nil
    self.menubarVisible = true
    self:menuTouched()
end

function Module:replaceMenubar(replacement)
    local menubar = self.menubar
    if menubar then
        for i,menu in ipairs(menubar) do
            self:hideWidget(menu.id)
        end
        replacement.parent = menubar
        replacement.selection = self.menuSelection

        self.menubar = replacement
        self.menuSelection = nil
    end
end

function Module:restoreMenubar()
    local menubar = self.menubar
    if menubar then
        if menubar.parent then
            -- destroy menubar widgets here
            self.menubar = menubar.parent
            self.menuSelection = menubar.selection
            for i,menu in ipairs(menubar) do
                self:showWidget(menu.id)
            end
        end
    end
end

function Module:updateMenus()
    local controller = self.controller
    local menubar = self.menubar
    if menubar then
        local time = system.getTime()
        local visible = time - self.menubarTime < 10
        if self.menubarVisible ~= visible then
            self.menubarVisible = visible
            if visible then
                self:showPanel("menu")
            else
                self:hidePanel("menu")
            end
        end

        if visible then
            for i,menu in ipairs(menubar) do
                if menu.validate then
                    menu:validate()
                end
                local text = menu.title
                if self.menuSelection == i then
                    text = string.format("%s   <==", text)
                else
                    text = string.format("%s", text)
                end
                self:updateWidgetText(menu.id, text)
            end
        end
    end
end

function Module:menuDebug(text, ...)
    --debug(text, ...)
end

function Module:menuTouched()
    self.menubarTime = system.getTime()
end

function Module:menuSelect()
    self:menuTouched()
    local selection = self.menuSelection
    if selection then
        local menu = self.menubar[selection]
        if menu then
            menu.action(menu)
        end
    end
end

function Module:menuBack()
    self:menuTouched()
    self:restoreMenubar()
end

function Module:menuPrevious()
    self:menuTouched()
    local selection = self.menuSelection or  #self.menubar + 1

    selection = selection - 1
    if selection == 0 then
        selection = #self.menubar
    end

    self.menuSelection = selection
end

function Module:menuNext()
    self:menuTouched()
    local selection = self.menuSelection or 0

    selection = selection + 1
    if selection > #self.menubar then
        selection = 1
    end

    self.menuSelection = selection
end

function Module:addMenu(id, title, action, validate)
    if self.menubar == nil then
        self:setupMenus()
    end

    local menu = { id = id, title = title, enabled = true, action = action, validate = validate }
    if validate then
        menu:validate()
    end
    table.insert(self.menubar, menu)
    self:addWidget(id, "text", "menu")
    return menu
end

function Module:addModuleMenu(id, title, module)
    local curriedAction
    local action = module[string.format("%sMenuAction", id)]
    if action then
        curriedAction = function(menu) action(module, menu) end
    end
    local curriedValidate
    local validate = module[string.format("%sMenuValidate", id)]
    if validate then
        curriedValidate = function(menu) validate(module, menu) end
    end
    return self:addMenu(id, title, curriedAction, curriedValidate)
end

function Module:addToggleMenu(id, onTitle, offTitle, object, getMethod, toggleMethod)
    if type(getMethod) == "string" then getMethod = object[getMethod] end
    local validation = function(menu)
        if getMethod(object, menu) then
            menu.title = menu.onTitle
        else
            menu.title = menu.offTitle
        end
    end
    if type(toggleMethod) == "string" then toggleMethod = object[toggleMethod] end
    local action = function(menu)
        toggleMethod(object, menu)
    end
    local menu = self:addMenu(id, offTitle, action, validation)
    menu.onTitle = onTitle
    menu.offTitle = offTitle
    return menu
end

function Module:selectMenu(id)
    self.menuSelection = nil
    for i,menu in ipairs(self.menubar) do
        if menu.id == id then
            self.menuSelection = i
        end
    end
end

function Module:switchOnSpace(object, doOnPlanet, doInSpace)
    local inSpace = self.flight:getState().inSpace
    if object.wasInSpace ~= inSpace then
        object.wasInSpace = inSpace
        if inSpace then
            object:doInSpace()
        else
            object:doOnPlanet()
        end
    end
end

return Module