local Text = require('samedicorp.modula.toolkit.text')
local Color = require('samedicorp.modula.toolkit.color')

local Button = {}

function Button.new(text, rect, options)
    if type(text) == "string" then
        text = Text.new(text)
    end

    if type(options) == "function" then
        options = { action = options }
    else
        options = options or {}
    end

    local style = options.style
    if type(style) == "string" then
        style = Button[style]
    end
    if not style then 
        style = Button.defaultStyle
    end

    local b = { 
        text = text, 
        rect = rect, 
        action = options.action,
        align = { h = _ENV.AlignH_Center, v = _ENV.AlignV_Baseline },
        drawInLayer = style
    }

    setmetatable(b, { __index = Button })

    return b
end

function Button:lineStyle(layer, isOver, isDown)
    local stroke
    local fill
    local text
    if isDown and isOver then
        stroke = Color.red
        text = Color.black
        fill = Color.white
    elseif isOver then
        stroke = Color.red
        text = Color.white
        fill = Color.black
    else
        stroke = Color.white
        text = Color.white
        fill = Color.black
    end

    self.rect:draw(layer.layer, stroke, fill, { radius = 8.0 })
    local lr = self.rect:inset(2)
    local anchor = lr:bottomMid()
    self.text:drawInLayer(layer, anchor, { fill = text, align = self.align })
end

function Button:defaultStyle(layer, isOver, isDown)
    local stroke
    local fill
    local text
    if isDown and isOver then
        stroke = Color.white
        text = Color.black
        fill = Color.white
    elseif isOver then
        stroke = Color.white
        text = Color.white
        fill = Color.new(1, 1, 1, 0.2)
    else
        stroke = Color.white
        text = Color.white
        fill = Color.black
    end

    self.rect:draw(layer.layer, stroke, fill)
    local lr = self.rect:inset(2)
    local anchor = lr:bottomMid()
    self.text:drawInLayer(layer, anchor, { fill = text, align = self.align })
end

function Button:hitTest(point)
    return self.rect:contains(point)
end

return Button