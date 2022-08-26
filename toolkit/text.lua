local Text = {}

local addText = _ENV.addText

function Text.new(text, font)
    local t = { text = text, font = font }
    setmetatable(t, { __index = Text })
    return t
end

function Text:drawInLayer(layer, x, y)
    local font = (self.font or layer.defaultFont).font
    addText(layer.layer, font, self.text, x, y)
end

return Text