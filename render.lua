-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = {}

function printf(format, ...)
    logMessage(string.format(tostring(format), ...))
end

debugf = printf

local getInput = _ENV.getInput
local requestAnimationFrame = _ENV.requestAnimationFrame
local addBox = _ENV.addBox
local setNextStrokeWidth = _ENV.setNextStrokeWidth
local getRenderCost = _ENV.getRenderCost
local getRenderCostMax = _ENV.getRenderCostMax

local Button = require('samedicorp.toolkit.button')
local Color = require('samedicorp.toolkit.color')
local Font = require('samedicorp.toolkit.font')
local Point = require('samedicorp.toolkit.point')
local Label = require('samedicorp.toolkit.label')
local Layer = require('samedicorp.toolkit.layer')
local Rect = require('samedicorp.toolkit.rect')
local Text = require('samedicorp.toolkit.text')
local Triangle = require('samedicorp.toolkit.triangle')

function Module:screenRect()
    local width, height = getResolution()
    return Rect.new(0, 0, width, height)
end

function Module:safeRect()
    return self:screenRect():inset(8)
end

function Module:interactive(cursor)
    local rate
    if self:screenRect():contains(cursor) then
        rate = 2
    else
        rate = 30
    end

    requestAnimationFrame(rate)
    return rate
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