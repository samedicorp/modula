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

local Box = {}
local Point = {}
local Rect = {}
local Color = {}
local Size = {}

function Rect.new(x, y, w, h)
    local r = { x = x, y = y, width = w, height = h }
    setmetatable(r, { __index = Rect })
    return r
end

function Box.new(rect)
    local b = { rect = rect }
    setmetatable(b, { __index = Box })
end

function Box:render(layer)
    local r = self.rect
    addBox(layer, r.x, r.y, r.width, r.height)
end

function Module:drawLines(text, x, y, width, height, fontName, fontSize)
    local layer = createLayer()
    local font = loadFont(fontName, fontSize)
    local lines = text:gmatch("[^\n]+")
    local i = 0

    local scrollBarWidth = 32
    local scrollButtonSize = scrollBarWidth - 2
    local scrollButtonX = x + width - scrollBarWidth + 1

    setNextFillColor(layer, 0, 0, 0, 1)
    setNextStrokeColor(layer, 1, 1, 1, 1)
    setNextStrokeWidth(layer, 1)
    addBox(layer, x + width - scrollBarWidth, y, scrollBarWidth, height)
    addBox(layer, scrollButtonX, y + 1, scrollButtonSize, scrollButtonSize)
    addBox(layer, scrollButtonX, y + height - 1, scrollBarWidth, scrollButtonSize)

    local s = self.scroll or 0
    local cx, cy = getCursor()
    if getCursorDown() and (cx > (width - scrollBarWidth)) then
        if cy > (height / 2) then
            self.scroll = s + 1
        elseif s > 0 then
            self.scroll = s - 1
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
end

return Module