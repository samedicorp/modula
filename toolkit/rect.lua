-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Point = require('samedicorp.modula.toolkit.point')

local Rect = { class = "rect" }

local addBox = _ENV.addBox
local setNextStrokeWidth = _ENV.setNextStrokeWidth

function Rect.new(x, y, w, h)
    local r = { x = x, y = y, width = w or 0, height = h or 0 }
    setmetatable(r, { __index = Rect })
    return r
end

function Rect.asRect(r)
    if not r.class then
        r = Rect.new(r[1], r[2], r[3], r[4])
    end
    return r
end

function Rect:inset(l,t,r,b)
    t = t or l
    r = r or l
    b = b or t
    return self.new(self.x + l, self.y + t, self.width - (l + r), self.height - (t + b))
end

function right()
    return self.x + self.width - 1
end

function bottom()
    return self.y + self.height - 1
end

function Rect:topLeft()
    return Point.new(self.x, self.y)
end

function Rect:midLeft()
    return self:topLeft():mid(self:bottomLeft())
end

function Rect:bottomLeft()
    return Point.new(self.x, self.y + self.height - 1)
end

function Rect:topRight()
    return Point.new(self.x + self.width - 1, self.y)
end

function Rect:midRight()
    return self:topRight():mid(self:bottomRight())
end

function Rect:bottomRight()
    return Point.new(self.x + self.width - 1, self.y + self.height - 1)
end

function Rect:topMid()
    return self:topLeft():mid(self:topRight())
end

function Rect:bottomMid()
    return self:bottomLeft():mid(self:bottomRight())
end

function Rect:contains(point)
    return (point.x >= self.x) and (point.y >= self.y) and (point.x < (self.x + self.width)) and (point.y < (self.y + self.height))
end

function Rect:draw(layer, stroke, fill, options)
    options = options or {}
    stroke:setNextStroke(layer)
    fill:setNextFill(layer)
    setNextStrokeWidth(layer, options.width or 1)
    if options.radius then
        addBoxRounded(layer, self.x, self.y, self.width, self.height, options.radius)
    else
        addBox(layer, self.x, self.y, self.width, self.height)
    end
end

return Rect