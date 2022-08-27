-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Point = require('samedicorp.modula.toolkit.point')
local Text = require('samedicorp.modula.toolkit.text')
local Widget = require('samedicorp.modula.toolkit.widget')

local Label = {}
setmetatable(Label, { __index = Widget })

function Label.new(text, xOrPosition, y)
    if type(text) == "string" then
        text = Text.new(text)
    end

    local l = { text = text }
    if y then
        l.position = Point.new(xOrPosition, y)
    else
        l.position = xOrPosition
    end

    setmetatable(l, { __index = Label })
    return l
end

function Label:drawInLayer(layer)
    self.text:drawInLayer(layer, self.position)
end

return Label