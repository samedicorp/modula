-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Font = {}

local loadFont = _ENV.loadFont

function Font.new(name, size)
    local f = { name = name, size = size, font = loadFont(name, size)}
    setmetatable(f, { __index = Font })
    return f
end

return Font