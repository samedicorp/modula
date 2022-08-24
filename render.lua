local Module = {}

local createLayer = _ENV.createLayer
local getResolution = _ENV.getResolution
local loadFont = _ENV.loadFont
local getInput = _ENV.getInput
local addText = _ENV.addText
local getCursor = _ENV.getCursor
local getCursorDown = _ENV.getCursorDown
local requestAnimationFrame = _ENV.requestAnimationFrame

function Module:drawLines(text, x, y, width, height, fontName, fontSize)
    local layer = createLayer()
    local font = loadFont(fontName, fontSize)
    local lines = text:gmatch("[^\n]+")
    local i = 0

    local s = self.scroll or 0
    local cx, cy = getCursor()
    if getCursorDown() then
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