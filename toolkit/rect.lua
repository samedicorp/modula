local Point = require('samedicorp.modula.toolkit.point')

local Rect = {}

local addBox = _ENV.addBox
local setNextStrokeWidth = _ENV.setNextStrokeWidth

function Rect.new(x, y, w, h)
    local r = { x = x, y = y, width = w, height = h }
    setmetatable(r, { __index = Rect })
    return r
end

function Rect:inset(l,t,r,b)
    t = t or l
    r = r or l
    b = b or t
    return self.new(self.x + l, self.y + t, self.width - (l + r), self.height - (t + b))
end

function Rect:topLeft()
    return Point.new(self.x, self.y)
end

function Rect:topRight()
    return Point.new(self.x + self.width - 1, self.y)
end

function Rect:bottomLeft()
    return Point.new(self.x, self.y + self.height - 1)
end

function Rect:bottomRight()
    return Point.new(self.x + self.width - 1, self.y + self.height - 1)
end

function Rect:contains(point)
    return (point.x >= self.x) and (point.y >= self.y) and (point.x < (self.x + self.width)) and (point.y < (self.y + self.height))
end

function Rect:draw(layer, stroke, fill, width)
    stroke:setNextStroke(layer)
    fill:setNextFill(layer)
    setNextStrokeWidth(layer, width or 1)
    addBox(layer, self.x, self.y, self.width, self.height)
end

return Rect