-- -=panels.lua-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 31/10/2020.
--  All code (c) 2020 - present day, The Samedi Corporation.
-- -=panels.lua-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = {}
local Widget = {}
local Panel = {}

function Module:register(modula, parameters)
    modula:registerForEvents({"onStart", "onStop"}, self)
    modula:registerService("panels", self)

    self.panels = {}
end

function Module:onStart()
    debugf("Panel manager running.")
end

function Module:onStop()
    for name,panel in pairs(self.panels) do
        panel:hide()
    end

    self.panels = {}
    debugf("Panel manager stopped.")
end

function Module:panelNamed(name)
    return self.panels[name]
end

function Module:addPanel(name, title, startHidden)
    local panel = { name = name, widgets = {}, title = title }
    setmetatable(panel, { __index = Panel })
    self.panels[name] = panel
    if not startHidden then
        panel:show()
    end
    return panel
end

function Panel:show()
    if not self.id then
        self.id = system.createWidgetPanel(self.title)
        for i,widget in ipairs(self.widgets) do
            widget:show()
        end
    end
end

function Panel:hide()
    if self.id then
        for i,widget in ipairs(self.widgets) do
            widget:hide()
        end
        system.destroyWidgetPanel(self.id)
        self.id = nil
    end
end

function Panel:addWidgets(widgets)
    local added = {}
    for name,widget in pairs(widgets) do
        if widget.label or widget.unit then
            widget.type = "value"
        else
            widget.type = "text"
        end
        local record = self:addWidget(name, widget.type)
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

function Panel:addWidget(name, type, data)
    local widget = { name = name, type = type, data = data, panel = self }
    setmetatable(widget, { __index = Widget })

    table.insert(self.widgets, widget)
    widget:show()
    return widget
end

function Widget:show()
    if not self.id then
        self.id = system.createWidget(self.panel.id, self.type)
        if self.data then
            system.addDataToWidget(self.data, self.id)
       end
    end
end

function Widget:hide()
    if self.id then
        system.destroyWidget(self.id)
        self.id = nil
    end
    if self.data then
        system.destroyData(self.data)
        self.data = nil
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