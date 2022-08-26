local Font = {}

local loadFont = _ENV.loadFont

function Font.new(name, size)
    local f = { name = name, size = size, font = loadFont(name, size)}
    setmetatable(f, { __index = Font })
    return f
end

return Font