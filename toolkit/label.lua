local Point = require('samedicorp.modula.toolkit.point')
local Text = require('samedicorp.modula.toolkit.text')
local Label = {}

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

function Label:hitTest(point)
    return false
end

return Label