local Module = {}

local createLayer = _ENV.createLayer
local getResolution = _ENV.getResolution
local loadFont = _ENV.loadFont
local getInput = _ENV.getInput
local addText = _ENV.addText
local getCursor = _ENV.getCursor
local getCursorDown = _ENV.getCursorDown
local requestAnimationFrame = _ENV.requestAnimationFrame
local addBox = _ENV.addBox
local addTriangle = _ENV.addTriangle
local setNextFillColor = _ENV.setNextFillColor
local setNextStrokeColor = _ENV.setNextStrokeColor
local setNextStrokeWidth = _ENV.setNextStrokeWidth

local Point = {}
local Rect = {}
local Triangle = {}
local Color = {}
local Size = {}

function Point.new(x, y)
    local p = { x = x, y = y}
    setmetatable(p, { __index = Point })
    return p
end

function Point:mid(p2)
    return Point.new((self.x + p2.x) / 2, (self.y + p2.y) / 2)
end


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

function Rect:draw(layer, stroke, fill, width)
    setNextStrokeColor(layer, stroke.red, stroke.green, stroke.blue, stroke.alpha)
    setNextFillColor(layer, fill.red, fill.green, fill.blue, fill.alpha)
    setNextStrokeWidth(layer, width or 1)
    addBox(layer, self.x, self.y, self.width, self.height)
end

function Triangle.new(p1, p2, p3)
    local t = { p1 = p1, p2 = p2, p3 = p3 }
    setmetatable(t, { __index = Triangle })
    return t
end

function Triangle:draw(layer, stroke, fill, width)
    setNextStrokeColor(layer, stroke.red, stroke.green, stroke.blue, stroke.alpha)
    setNextFillColor(layer, fill.red, fill.green, fill.blue, fill.alpha)
    setNextStrokeWidth(layer, width or 1)
    addTriangle(layer, self.p1.x, self.p1.y, self.p2.x, self.p2.y, self.p3.x, self.p3.y)
end

function Color.new(r, g, b, a)
    local c = { red = r, green = g, blue = b, alpha = a or 1}
    setmetatable(c, { __index = Color })
    return c
end

local white = Color.new(1, 1, 1)
local black = Color.new(0, 0, 0)

function Module:safeRect()
    local width, height = getResolution()
    return Rect.new(0, 0, width, height):inset(8)
end

function Module:textField(text, rect, fontName, fontSize)
    local lines = text:gmatch("[^\n]+")
    self:textLineField(lines, rect, fontName, fontSize)
end

function Module:textLineField(lines, rect, fontName, fontSize)
    local layer = createLayer()
    local font = loadFont(fontName, fontSize)
    local i = 0
    local x = rect.x
    local y = rect.y
    local width = rect.width
    local height = rect.height

    local scrollBarWidth = 24

    local bar = Rect.new(x + width - scrollBarWidth + 1, y, scrollBarWidth, height - 1)
    local barIn = bar:inset(4)

    local upFill = black
    local downFill = black

    local s = self.scroll or 0
    local cx, cy = getCursor()
    if getCursorDown() and (cx > (width - scrollBarWidth)) then
        if cy > (height / 2) then
            self.scroll = s + 1
            downFill = white
        elseif s > 0 then
            self.scroll = s - 1
            upFill = white
        end
    end

    for i,w in ipairs(lines) do
        if i >= s then
            y = y + fontSize
            addText(layer, font, w, x, y)
            if y > height then
                break
            end
        end
        i = i + 1
    end 

    bar:draw(layer, white, black)
    local barInH = barIn.height
    barIn.height = barIn.width
    local upT = Triangle.new(barIn:bottomLeft(), barIn:bottomRight(), barIn:topLeft():mid(barIn:topRight()))
    upT:draw(layer, white, upFill)
    barIn.y = barIn.y + barInH - barIn.width
    local downT = Triangle.new(barIn:topLeft(), barIn:topRight(), barIn:bottomLeft():mid(barIn:bottomRight()))
    downT:draw(layer, white, downFill)

end

Module.Point = Point
Module.Rect = Rect
Module.Color = Color

return Module