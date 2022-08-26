local Color = {}

local setNextFillColor = _ENV.setNextFillColor
local setNextStrokeColor = _ENV.setNextStrokeColor

function Color.new(r, g, b, a)
    local c = { red = r, green = g, blue = b, alpha = a or 1}
    setmetatable(c, { __index = Color })
    return c
end

Color.white = Color.new(1, 1, 1)
Color.black = Color.new(0, 0, 0)

function Color:setNextStroke(layer)
    setNextStrokeColor(layer, self.red, self.green, self.blue, self.alpha)
end

function Color:setNextFill(layer)
    setNextFillColor(layer, self.red, self.green, self.blue, self.alpha)
end

return Color