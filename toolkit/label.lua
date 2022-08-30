-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Point = require('samedicorp.modula.toolkit.point')
local Rect = require('samedicorp.modula.toolkit.rect')
local Text = require('samedicorp.modula.toolkit.text')
local Widget = require('samedicorp.modula.toolkit.widget')

local Label = {}
setmetatable(Label, { __index = Widget })

function Label.new(rect, text)
    local l = { text = Text.asText(text), rect = Rect.asRect(rect) }
    setmetatable(l, { __index = Label })
    Widget.init(l)
    return l
end

function Label:hitTest(cursor)
    return false
end

function Label:drawInLayer(layer)
    self.text:drawInLayer(layer, self.rect)
end

return Label