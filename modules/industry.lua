-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 09/10/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- This module tracks any industry units connected to the core.

local Module = { }
local Industry = {}

function Module:register(parameters)
    parameters = parameters or {}

    self.industry = {}

    modula:registerService(self, "industry")
    self:findIndustry()
end

-- ---------------------------------------------------------------------
-- Event handlers
-- ---------------------------------------------------------------------



-- ---------------------------------------------------------------------
-- Internal
-- ---------------------------------------------------------------------

function Module:findIndustry()
    local industry = {}
    local core = modula.core
    local elementIDs = core.getElementIdList()
    for elementID in ipairs(elementIDs) do
        local class = core.getElementClassById(elementID)
        if class == "Industry1" then
            local item = { 
                localID = elementID,
                class = class,
                name = core.getElementDisplayNameById(elementID),
                label = core.getElementNameById(elementID)
            }
            setmetatable(item, { __index = Industry })

            table.insert(industry, item)
        end
    end

    self.industry = industry
end

return Module