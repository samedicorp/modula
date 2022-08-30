-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Widget = { class = "widget" }

function Widget:init()
    self.widgets = {}
end

function Widget:hitTest(point)
    return self.rect:contains(point)
end

function Widget:mouseDown(pos)
    if self.onMouseDown then
        self.onMouseDown(pos, self)
    end
end

function Widget:mouseDrag(pos)
    if self.onMouseDrag then
        self.onMouseDrag(pos, self)
    end
end

function Widget:mouseUp(pos)
    if self.onMouseUp then
        self.onMouseUp(pos, self)
    end
end

function Widget:addWidget(widget)
    table.insert(self.widgets, widget)
end

function Widget:renderAll(layer, cursor, isDown)
    local over
    local isOver = self:hitTest(cursor)
    if isOver then
        over = self
    end

    for i,widget in ipairs(self.widgets) do
        over = widget:renderAll(layer, cursor, isDown) or over
    end

    self:drawInLayer(layer, isOver, isDown)
    return over
end

function Widget:drawInLayer(layer, isOver, isDown)
end


return Widget