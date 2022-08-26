local Module = {}

local getResolution = _ENV.getResolution
local getInput = _ENV.getInput
local requestAnimationFrame = _ENV.requestAnimationFrame
local addBox = _ENV.addBox
local setNextStrokeWidth = _ENV.setNextStrokeWidth
local getRenderCost = _ENV.getRenderCost
local getRenderCostMax = _ENV.getRenderCostMax

local Button = require('samedicorp.modula.toolkit.button')
local Color = require('samedicorp.modula.toolkit.color')
local Font = require('samedicorp.modula.toolkit.font')
local Point = require('samedicorp.modula.toolkit.point')
local Label = require('samedicorp.modula.toolkit.label')
local Layer = require('samedicorp.modula.toolkit.layer')
local Rect = require('samedicorp.modula.toolkit.rect')
local Text = require('samedicorp.modula.toolkit.text')
local Triangle = require('samedicorp.modula.toolkit.triangle')

function Module:screenRect()
    local width, height = getResolution()
    return Rect.new(0, 0, width, height)
end

function Module:safeRect()
    return self:screenRect():inset(8)
end


Module.Point = Point.new
Module.Rect = Rect.new
Module.Color = Color.new
Module.Button = Button.new
Module.Font = Font.new
Module.Text = Text.new
Module.Layer = Layer.new
Module.Label = Label.new

return Module