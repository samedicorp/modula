-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 09/10/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- This module tracks any industry units connected to the core.

local Module = {}
local Machine = {}
local Product = {}

function Module:register(parameters)
    parameters = parameters or {}

    modula:registerService(self, "industry")
    modula:registerForEvents(self, "onStart", "onStop")
    modula:subclassElement(Machine)

    --self:findIndustry()
    self:findIndustryElements("Industry1")
end

-- ---------------------------------------------------------------------
-- Event handlers
-- ---------------------------------------------------------------------

function Module:onStart()
    debugf("Industry started.")
end

function Module:onStop()
    debugf("Industry stopped.")
end

-- ---------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------

function Module:getMachines()
    return self.machines
end

function Module:reportMachines()
    local machines = self:getMachines()
    for i, machine in ipairs(machines) do
        debugf("Found %s '%s'", machine:label(), machine:name())
        debugf("State is %s", machine:status())

        for _, product in pairs(machine:products()) do
            debugf("  Producing: %s x%d", product:getName(), product.quantity)
        end
    end
end

function Module:withMachines(fn)
    local machines = self:getMachines()
    for i, machine in ipairs(machines) do
        fn(machine)
    end
end

-- ---------------------------------------------------------------------
-- Internal
-- ---------------------------------------------------------------------

function Module:findIndustryElements(...)
    local machines = {}
    for i, class in ipairs({ ... }) do
        modula:withElements(class, function(element)
            local meta = getmetatable(element)
            meta.__index = Machine
            setmetatable(element, meta)
            table.insert(machines, element)
            -- debugf("Found %s '%s' %s", element:label(), element:name(), element.object.getClass())
        end)
    end
    self.machines = machines
end

function Machine:info()
    return self.object.getInfo()
end

function Machine:state()
    return self:info().state
end

function Machine:status()
    local state = self:state()
    return state == 1 and "Stopped" or
        state == 2 and "Running" or
        state == 3 and "Missing Ingredients" or
        state == 4 and "Full" or
        state == 5 and "Missing Output Container" or
        state == 6 and "Pending" or
        state == 7 and "Missing Schematics" or
        "Unknown"
end

function Machine:isStopped()
    return self:state() == 1
end

function Machine:isRunning()
    return self:state() == 2
end

function Machine:isPending()
    return self:state() == 6
end

function Machine:isFull()
    return self:state() == 4
end

function Machine:isMissingIngredients()
    return self:state() == 3
end

function Machine:isMissingSchematics()
    return self:state() == 7
end

function Machine:isMissingOutputContainer()
    return self:state() == 5
end

function Machine:recipe()
    return self.object.getOutputs()[1]
end

function Machine:mainProduct()
    return self:products()[1]
end

function Machine:products()
    local products = {}
    for n, info in pairs(self.object.getOutputs()) do
        local product = {
            id = info.id,
            quantity = info.quantity,
            info = system.getItem(info.id)
        }
        setmetatable(product, { __index = Product })
        table.insert(products, product)
    end
    return products
end

function Machine:setRecipe(recipeId)
    return self.object.setOutput(recipeId)
end

function Machine:start()
    self.object.startRun()
end

function Machine:stop()
    self.object.stop()
end

function Product:getName()
    return self.info.locDisplayName
end

function Product:getIcon()
    return self.info.iconPath
end

return Module
