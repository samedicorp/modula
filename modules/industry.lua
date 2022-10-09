-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 09/10/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- This module tracks any industry units connected to the core.

local Module = { }

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
-- Public API
-- ---------------------------------------------------------------------

function Module:getMachines()
    return self.industry
end

-- ---------------------------------------------------------------------
-- Internal
-- ---------------------------------------------------------------------

local Machine = {}
local Product = {}

function Module:findIndustry()
    local industry = {}
    local core = modula.core
    local elementIDs = core.getElementIdList()
    for i,elementID in ipairs(elementIDs) do
        local class = core.getElementClassById(elementID)
        if class == "Industry1" then
            local info = core.getElementIndustryInfoById(elementID)
            local item = { 
                localID = elementID,
                class = class,
                name = core.getElementDisplayNameById(elementID),
                label = core.getElementNameById(elementID),
                info = info
            }

            local productInfos = {}
            for n, productInfo in pairs(info.currentProducts) do
                local product = { 
                    id = productInfo.id,
                    quantity = productInfo.quantity
                }
                product.info = system.getItem(productInfo.id)
                setmetatable(product, { __index = Product })
                table.insert(productInfos, product)
            end

            item.products = productInfos
            item.mainProduct = productInfos[1]

            setmetatable(item, { __index = Machine })
            table.insert(industry, item)
        end
    end

    self.industry = industry
end

function Product:getName()
    return self.info.locDisplayName
end

function Product:getIcon()
    return self.info.iconPath
end


return Module