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
local setNextFillColor = _ENV.setNextFillColor
local setNextStrokeColor = _ENV.setNextStrokeColor
local setNextStrokeWidth = _ENV.setNextStrokeWidth

local Point = {}
local Rect = {}
local Color = {}
local Size = {}

function Rect.new(x, y, w, h)
    local r = { x = x, y = y, width = w, height = h }
    setmetatable(r, { __index = Rect })
    return r
end

function Rect:drawBox(layer, stroke, fill)
    setNextStrokeColor(layer, stroke.red, stroke.green, stroke.blue, stroke.alpha)
    setNextFillColor(layer, fill.red, fill.green, fill.blue, fill.alpha)
    setNextStrokeWidth(layer, 1)
    addBox(layer, self.x, self.y, self.width, self.height)
end


-- local Box = {}
-- function Box.new(rect)
--     local b = { rect = rect }
--     setmetatable(b, { __index = Box })
--     return b
-- end
-- function Box:render(layer, stroke, fill)
--     local r = self.rect

--     setNextStrokeColor(layer, stroke.red, stroke.green, stroke.blue, stroke.alpha)
--     setNextFillColor(layer, fill.red, fill.green, fill.blue, fill.alpha)
--     setNextStrokeWidth(layer, 1)
--     addBox(layer, r.x, r.y, r.width, r.height)
-- end

function Color.new(r, g, b, a)
    local c = { red = r, green = g, blue = b, alpha = a or 1}
    setmetatable(c, { __index = Color })
    return c
end

local white = Color.new(1, 1, 1)
local black = Color.new(0, 0, 0)

function Module:textField(text, x, y, width, height, fontName, fontSize)
    local layer = createLayer()
    local font = loadFont(fontName, fontSize)
    local lines = text:gmatch("[^\n]+")
    local i = 0

    local scrollBarWidth = 24
    local scrollButtonSize = scrollBarWidth - 2
    local scrollButtonX = x + width - scrollBarWidth + 1

    local bar = Rect.new(x + width - scrollBarWidth + 1, y, scrollBarWidth, height - 1)
    local up = Rect.new(scrollButtonX, y + 1, scrollButtonSize, scrollButtonSize)
    local down = Rect.new(scrollButtonX, y + height - 1 - scrollButtonSize, scrollBarWidth, scrollButtonSize)

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

    for w in lines do
        if i >= s then
            addText(layer, font, w, x, y)
            y = y + fontSize
            if y > height then
                break
            end
        end
        i = i + 1
    end 

    bar:drawBox(layer, white, black)
    up:drawBox(layer, white, upFill)
    down:drawBox(layer, white, downFill)

end

return Module