local Text = require('samedicorp.modula.toolkit.text')
local Color = require('samedicorp.modula.toolkit.color')
local Widget = require('samedicorp.modula.toolkit.widget')

local Button = {}
setmetatable(Button, { __index = Widget })

function Button.new(text, rect, options)
    if type(text) == "string" then
        text = Text.new(text)
    end

    if type(options) == "function" then
        options = { onMouseUp = options }
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
        onMouseDown = options.onMouseDown,
        onMouseDrag = options.onMouseDrag,
        onMouseUp = options.onMouseUp,
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

function Button:mouseDown(pos)
    if self.onMouseDown then
        self.onMouseDown(pos, self)
    end
end

function Button:mouseDrag(pos)
    if self.onMouseDrag then
        self.onMouseDrag(pos, self)
    end
end

function Button:mouseUp(pos)
    if self.onMouseUp then
        self.onMouseUp(pos, self)
    end
end

return Button