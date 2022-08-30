-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Color = require('samedicorp.modula.toolkit.color')
local Rect = require('samedicorp.modula.toolkit.rect')
local Widget = require('samedicorp.modula.toolkit.widget')

local Bar = {}
setmetatable(Bar, { __index = Widget })

function Bar.new(rect, value)
    local b = { rect = Rect.asRect(rect), value = value }
    setmetatable(b, { __index = Bar })
    Widget.init(b)
    return b
end

function Bar:drawInLayer(layer)
    local inset = self.rect.width * (1.0 - self.value)
    self.rect:draw(layer.layer, Color.white, Color.black)
    local r = self.rect:inset(0, 0, inset, 0)
    r:draw(layer.layer, Color.white, Color.white)
end

return Bar