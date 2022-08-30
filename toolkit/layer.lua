-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Bar = require('samedicorp.modula.toolkit.bar')
local Button = require('samedicorp.modula.toolkit.button')
local Color = require('samedicorp.modula.toolkit.color')
local Font = require('samedicorp.modula.toolkit.font')
local Label = require('samedicorp.modula.toolkit.label')
local Point = require('samedicorp.modula.toolkit.point')
local Rect = require('samedicorp.modula.toolkit.rect')
local Screen = require('samedicorp.modula.toolkit.screen')
local Triangle = require('samedicorp.modula.toolkit.triangle')
local Widget = require('samedicorp.modula.toolkit.widget')

local Layer = { }
setmetatable(Layer, { __index = Widget })

local createLayer = _ENV.createLayer
local addText = _ENV.addText
local requestAnimationFrame = _ENV.requestAnimationFrame

function Layer.new(rect)
    local screen = Screen.default
    local l = { 
        rect = rect or screen:safeRect(),
        layer = createLayer(),
        widgets = {},
        defaultFont = Font.new("Play", 20),
        screen = screen
    }
    Widget.init(l)

    setmetatable(l, { __index = Layer })
    return l
end

function Layer:draw(object)
    object:drawInLayer(self)
end

function Layer:render()
    local r = self.rect
    setLayerClipRect(self.layer, 0, 0, r.width, r.height)
    setLayerTranslation(self.layer, r.x, r.y)

    local cursor = self.screen:cursor()
    local isDown = self.screen:isCursorDown()

    local over = self:renderAll(self, cursor, isDown)
    self.over = over

    if isDown and over and not clickedWidget then
        clickedWidget = over
        clickedWidget:mouseDown(cursor)
    elseif not isDown and clickedWidget then
        clickedWidget:mouseUp(cursor)
        clickedWidget = nil
    elseif isDown and clickedWidget then
        clickedWidget:mouseDrag(cursor)
    end
end


function Layer:addButton(...)
    local button = Button.new(...)
    self:addWidget(button)
    return button
end

function Layer:addLabel(...)
    local label = Label.new(...)
    self:addWidget(label)
    return label
end

function Layer:addBar(...)
    local bar = Bar.new(...)
    self:addWidget(bar)
    return bar
end

function Layer:scheduleRefresh()
    local rate
    if self.screen:isFocussed() then
        rate = 2
    else
        rate = 30
    end

    requestAnimationFrame(rate)
    return rate
end

function Layer:textField(text, rect, font)
    local lines = text:gmatch("[^\n]+")
    self:textLineField(lines, rect, font)
end

function Layer:textLineField(lines, rect, font)
    local layer = self.layer
    local font = font or self.defaultFont
    local i = 0
    local x = rect.x
    local y = rect.y
    local width = rect.width
    local height = rect.height

    local scrollBarWidth = 24

    local bar = Rect.new(x + width - scrollBarWidth + 1, y, scrollBarWidth, height - 1)
    local barIn = bar:inset(4)

    local upFill = Color.black
    local downFill = Color.black

    local s = self.scroll or 0
    local cursor = Screen.default:cursor()
    if Screen.default:isCursorDown() and (cursor.x > (width - scrollBarWidth)) then
        if cursor.y > (height / 2) then
            self.scroll = s + 1
            downFill = Color.white
        elseif s > 0 then
            self.scroll = s - 1
            upFill = Color.white
        end
    end

    for i,w in ipairs(lines) do
        if i >= s then
            y = y + font.size
            addText(layer, font.font, w, x, y)
            if y > height then
                break
            end
        end
        i = i + 1
    end 

    -- local text = string.format('render cost: %.02f', getRenderCost() / getRenderCostMax()) 
    -- addText(layer, font, text, 10, 20)

    bar:draw(layer, Color.white, Color.black)
    local barInH = barIn.height
    barIn.height = barIn.width
    local upT = Triangle.new(barIn:bottomLeft(), barIn:bottomRight(), barIn:topLeft():mid(barIn:topRight()))
    upT:draw(layer, Color.white, upFill)
    barIn.y = barIn.y + barInH - barIn.width
    local downT = Triangle.new(barIn:topLeft(), barIn:topRight(), barIn:bottomLeft():mid(barIn:bottomRight()))
    downT:draw(layer, Color.white, downFill)
end

return Layer