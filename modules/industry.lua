-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 09/10/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- This module tracks any industry units connected to the core.

local Module = {}
local Machine = {}
local Product = {}
local Input = {}

function Module:register(parameters)
    parameters = parameters or {}

    modula:registerService(self, "industry")
    modula:registerForEvents(self, "onStart", "onStopping")
    modula:subclassElement(Machine)

    --self:findIndustry()
    self:findIndustryElements("Industry1", "Industry2", "Industry3", "Industry4", "Industry5")
end

-- ---------------------------------------------------------------------
-- Event handlers
-- ---------------------------------------------------------------------

function Module:onStart()
    debugf("Industry started.")
end

function Module:onStopping()
    debugf("Industry stopping.")
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
        debugf("\nFound %s '%s' - %s", machine:label(), machine:name(), machine:status())

        for _, product in pairs(machine:products()) do
            debugf("- %s x%s", product.name, product.quantity or 0)
        end
    end
end

function Module:withMachines(fn)
    local machines = self:getMachines()
    for i, machine in ipairs(machines) do
        fn(machine)
    end
end

function Module:productForItem(item)
    if not item then
        return nil
    end
    local info = system.getItem(item)
    local recipes = system.getRecipes(item)

    local product = {
        id = item,
        info = info,
        name = info.locDisplayName,
        recipes = recipes,
    }

    setmetatable(product, { __index = Product })
    return product
end

function Product:mainRecipe(producer)
    local maxQuantity = -1
    local mainRecipe
    for i, recipe in ipairs(self.recipes) do
        for j, product in ipairs(recipe.products) do
            if (product.id == self.id) and product.quantity > maxQuantity then
                if (producer == nil) or self:recipeProducedBy(recipe, producer) then
                    mainRecipe = recipe
                    recipe.mainProduct = product
                    maxQuantity = product.quantity
                end
            end
        end
    end

    return mainRecipe
end

function Product:recipeProducedBy(recipe, producer)
    for i, machineId in ipairs(recipe.producers) do
        if machineId == producer then
            return true
        end
    end
    return false
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
            element.industry = self
            -- debugf("Found %s '%s' %s", element:label(), element:name(), element.object.getClass())
        end)
    end
    self.machines = machines
end

function Machine:info()
    return self.object.getInfo()
end

function Machine:itemId()
    return self.object.getItemId()
end

function Machine:class()
    return self.object.getClassId()
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
    return self:productForOutput(self.object.getOutputs()[1])
end

function Machine:inputs()
    local inputs = {}
    for n, output in pairs(self.object.getInputs()) do
        local product = self:productForOutput(output)
        if product then
            table.insert(inputs, product)
        end
    end

    return inputs
end

function Machine:products()
    local products = {}
    for n, output in pairs(self.object.getOutputs()) do
        local product = self:productForOutput(output)
        if product then
            table.insert(products, product)
        end
    end

    return products
end

function Machine:productForOutput(output)
    if not output then
        return nil
    end

    return self.industry:productForItem(output.id)
end

function Machine:setRecipe(recipeId)
    local result = self.object.setOutput(recipeId)
    return result
end

function Machine:start(amount)
    amount = amount or 0
    if amount > 0 then
        self.object.startMaintain(amount)
    else
        self.object.startRun()
    end
end

function Machine:stop()
    return self.object.stop(true)
end

return Module
