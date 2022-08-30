-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Widget = { class = "widget" }

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

return Widget