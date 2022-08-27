-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Text = {}

local addText = _ENV.addText
local setNextTextAlign = _ENV.setNextTextAlign

function Text.new(text, font, color, options)
    local t = { text = text, font = font, options = options or {} }
    setmetatable(t, { __index = Text })
    return t
end

function Text:drawInLayer(layer, position, explicitOptions)
    local options = explicitOptions or {}
    local font = (self.font or layer.defaultFont).font
    local fill = options.fill or self.options.fill
    if fill then
        fill:setNextFill(layer.layer)
    end
    local align = options.align or self.options.align
    if align then
        setNextTextAlign(layer.layer, align.h, align.v)
    end
    addText(layer.layer, font, self.text, position.x, position.y)
end

return Text

-- AlignH_Left, AlignH_Center, AlignH_Right
-- AlignV_Ascender, AlignV_Top, AlignV_Middle, AlignV_Baseline, AlignV_Bottom, AlignV_Descender