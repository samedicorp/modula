-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 30/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Bar = require('samedicorp.modula.toolkit.bar')
local Font = require('samedicorp.modula.toolkit.font')
local Label = require('samedicorp.modula.toolkit.label')
local Rect = require('samedicorp.modula.toolkit.rect')
local Text = require('samedicorp.modula.toolkit.text')
local Widget = require('samedicorp.modula.toolkit.widget')

Chart = { __index = Widget, super = Widget }

function Chart.new(rect, bars, fontName)
    local c = { 
        rect = Rect.asRect(rect), 
        widgets = {},
        font = font
    }

    setmetatable(c, { __index = Chart })
    Chart.super.init(c)

    local count = 0
    for _,_ in pairs(bars) do
        count = count + 1
    end

    local y = 0
    local labelSize = rect.height / (5 * count)
    local labelFont = Font.new(fontName, labelSize)
    local barHeight = (rect.height / (count)) - labelFont.size
    local barWidth = rect.width

    for name,bar in pairs(bars) do
        local percent = math.floor(bar.value * 100)
        c:addWidget(Bar.new({0, y, barWidth, barHeight}, bar.value))
        y = y + barHeight + labelFont.size
        c:addWidget(Label.new({ 0, y - 4}, Text.new(name, labelFont)))
        c:addWidget(Label.new({ rect.width - (barWidth / 2), y }, Text.new(string.format("%d%%", percent), labelFont)))
    end

    return c


end

function Chart:addWidget(widget)
    table.insert(self.widgets, widget)
end



return Chart