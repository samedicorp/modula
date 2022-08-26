local Text = require('samedicorp.modula.toolkit.text')
local Color = require('samedicorp.modula.toolkit.color')

local Button = {}

function Button.new(text, rect, action)
    if type(text) == "string" then
        text = Text.new(text)
    end

    local b = { 
        text = text, 
        rect = rect, 
        action = action,
        align = { h = _ENV.AlignH_Center, v = _ENV.AlignV_Baseline }
    }

    setmetatable(b, { __index = Button })
    return b
end

function Button:drawInLayer(layer, isOver, isDown)
    local stroke
    local fill
    if isDown then
        stroke = Color.black
        fill = Color.white
    else
        stroke = Color.white
        fill = Color.black
    end

    self.rect:draw(layer.layer, stroke, fill)
    local lr = self.rect:inset(2)
    local anchor = lr:bottomLeft():mid(lr:bottomRight())
    self.text:drawInLayer(layer, anchor.x, anchor.y, { fill = stroke, align = self.align })
end

function Button:hitTest(point)
    return self.rect:contains(point)
end

return Button