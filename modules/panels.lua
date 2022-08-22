-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 31/10/2020.
--  All code (c) 2020 - present day, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = {}
local Widget = {}

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
    self.modula:call("onWidgetUpdate", self)
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

function Module:addWidgets(panel, widgets)
    local added = {}
    for name,widget in pairs(widgets) do
        if widget.label or widget.unit then
            widget.type = "value"
        else
            widget.type = "text"
        end
        local record = self:addWidget(name, widget.type, panel)
        added[name] = record
        for k,v in pairs(widget) do
            record[k] = v
        end
        if widget.value then
            record:update(widget.value)
        end
    end
    return added
end

function Module:addWidget(name, type, panelName, data)
    self:panelDebug("adding widget %s for panel %s", name, panelName)
    local panel = self.panels[panelName]
    if not panel then
        self:panelDebug("panel %s missing - using default", panelName)
        panel = self.panels["default"]
    end

    local widget = { name = name, type = type, data = data, panel = panel }
    setmetatable(widget, { __index = Widget })

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


function Widget:update(...)
    if self.type == "text" then
        self:updateText(...)
    elseif self.type == "value" then
        self:updateValue(...)
    end
end

function Widget:updateText(text, ...)
    local json = string.format('{"text": "%s "}', string.format(text, ...))
    if not self.data then
        self.data = system.createData(json)
        if self.id then
            system.addDataToWidget(self.data, self.id)
        end
    else
        system.updateData(self.data, json)
    end
end

function Widget:updateValue(value)
    local json = string.format('{"label": "%s ", "value": "%s", "unit": "%s"}', self.label, value, self.units or "")
    if not self.data then
        self.data = system.createData(json)
        if self.id then
            system.addDataToWidget(self.data, self.id)
        end
    else
        system.updateData(self.data, json)
    end
end

function Widget:updateFloat(value)
    self:updateValue(string.format("%.2f", value))
end

function Widget:updateVector(value)
    self:updateValue(string.format("%+.1f %+.1f %+.1f", value.x, value.y, value.z))
end

function Widget:updateTime(value)
    self:update(self:time(value))
end

function Widget:time(seconds)
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