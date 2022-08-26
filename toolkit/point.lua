local Point = {}

function Point.new(x, y)
    local p = { x = x, y = y}
    setmetatable(p, { __index = Point })
    return p
end

function Point:mid(p2)
    return Point.new((self.x + p2.x) / 2, (self.y + p2.y) / 2)
end

return Point