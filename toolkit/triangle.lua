-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Triangle = {}

local addTriangle = _ENV.addTriangle
local setNextStrokeWidth = _ENV.setNextStrokeWidth

function Triangle.new(p1, p2, p3)
    local t = { p1 = p1, p2 = p2, p3 = p3 }
    setmetatable(t, { __index = Triangle })
    return t
end

function Triangle:draw(layer, stroke, fill, width)
    stroke:setNextStroke(layer)
    fill:setNextFill(layer)
    setNextStrokeWidth(layer, width or 1)
    addTriangle(layer, self.p1.x, self.p1.y, self.p2.x, self.p2.y, self.p3.x, self.p3.y)
end

return Triangle