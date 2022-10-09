-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 09/10/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- This module tracks any industry units connected to the core.

local Module = { }

function Module:register(parameters)
    parameters = parameters or {}

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
    return self.machines
end

-- ---------------------------------------------------------------------
-- Internal
-- ---------------------------------------------------------------------

local Machine = {}
local Product = {}

function Module:findIndustry()
    local machines = {}
    local core = modula.core
    local elementIDs = core.getElementIdList()
    for i,elementID in ipairs(elementIDs) do
        local class = core.getElementClassById(elementID)
        if class:find("Industry", 1, true) == 1 then
            local machine = core.getElementIndustryInfoById(elementID)
            machine.localID = elementID
            machine.class = class
            machine.name = core.getElementDisplayNameById(elementID)
            machine.label = core.getElementNameById(elementID)

            local productInfos = {}
            for n, productInfo in pairs(machine.currentProducts) do
                local product = { 
                    id = productInfo.id,
                    quantity = productInfo.quantity
                }
                product.info = system.getItem(productInfo.id)
                setmetatable(product, { __index = Product })
                table.insert(productInfos, product)
            end

            machine.products = productInfos
            machine.mainProduct = productInfos[1]

            setmetatable(machine, { __index = Machine })
            table.insert(machines, machine)
        end
    end

    self.machines = machines
end

function Machine:isStopped()
    return self.state == 1
end

function Machine:isRunning()
    return self.state == 2
end

function Machine:isPending()
    return self.state == 6
end

function Machine:isFull()
    return self.state == 4
end

function Machine:isMissingIngredients()
    return self.state == 3
end

function Machine:isMissingSchematics()
    return self.state == 7
end

function Machine:isMissingOutputContainer()
    return self.state == 5
end

function Product:getName()
    return self.info.locDisplayName
end

function Product:getIcon()
    return self.info.iconPath
end


return Module