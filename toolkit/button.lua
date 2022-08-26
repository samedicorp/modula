local Text = require('samedicorp.modula.toolkit.text')
local Color = require('samedicorp.modula.toolkit.color')

local Button = {}

function Button.new(label, rect)
    if type(label) == "string" then
        label = Text.new(label)
    end

    local b = { 
        label = label, 
        rect = rect, 
    }

    setmetatable(b, { __index = Button })
    return b
end

function Button:drawInLayer(layer)
    self.rect:draw(layer.layer, Color.white, Color.black)
    local lr = self.rect:inset(2)
    self.label:drawInLayer(layer, lr.x, lr.y + lr.height)
end

return Button