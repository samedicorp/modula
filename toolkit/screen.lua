-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 27/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Point = require('samedicorp.modula.toolkit.point')
local Rect = require('samedicorp.modula.toolkit.rect')

local Screen = {}

local getResolution = _ENV.getResolution
local getCursor = _ENV.getCursor
local getCursorDown = _ENV.getCursorDown

function Screen.new() 
    local s = {}
    setmetatable(s, { __index = Screen })
    return s
end

Screen.default = Screen.new()

function Screen:rect()
    local width, height = getResolution()
    return Rect.new(0, 0, width, height)
end

function Screen:safeRect()
    return self:rect():inset(8)
end

function Screen:cursor()
    local x,y = getCursor()
    return Point.new(x, y)
end

function Screen:isCursorDown()
    return getCursorDown()
end

function Screen:isFocussed()
    return self:rect():contains(self:cursor())
end

return Screen