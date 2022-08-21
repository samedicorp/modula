-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 31/10/2020.
--  All code (c) 2020 - present day, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = {}

function Module:register(modula, parameters)
    modula:registerForEvents({"onStart", "onStop", "onFastUpdate"}, self)
    modula:registerService("panels", self)

    self.widgetRecords = {}
    self.panels = {}
end

function Module:onStart()
    self:addPanel("default", "Display", true)
    debug("Panel manager running.")
end

function Module:onStop()
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
    debug("Panel manager stopped.")
end

function Module:onFastUpdate()
    -- local flight = self.flight
    -- local controller = self.controller
    -- local core = controller:getCore()

    self.modula:call("onDisplayUpdate", self)
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

return Module