-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Point = {}

function Point.new(x, y)
    local p = { x = x, y = y}
    setmetatable(p, { __index = Point })
    return p
end

function Point:mid(p2)
    return Point.new((self.x + p2.x) / 2, (self.y + p2.y) / 2)
end

function Point:minus(point)
    return Point.new(self.x - point.x, self.y - point.y)
end

function Point:plus(point)
    return Point.new(self.x + point.x, self.y + point.y)
end

return Point