local Text = require('samedicorp.modula.toolkit.text')
local Label = {}

function Label.new(text, x, y)
    if type(text) == "string" then
        text = Text.new(text)
    end

    local l = { text = text, x = x, y = y }
    setmetatable(l, { __index = Label })
    return l
end

function Label:drawInLayer(layer)
    self.text:drawInLayer(layer, self.x, self.y)
end

return Label