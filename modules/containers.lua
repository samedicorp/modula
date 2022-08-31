-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 31/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- This module tracks any containers connected to the core, and sends out
-- an onContainerChanged event when their contents or fullness changes.

-- The container fullness is calculated as a percentage of the max volume.
-- The module also optionally requests the actual contents from the containers,
-- which uses a rate-limited API, and manages collating the responses.

-- Clients of this service send the module a list of the container classes
-- that they are interested in, and then listen for onContainerChanged events.

local Module = { }

function Module:register(parameters)
    parameters = parameters or {}

    self.monitorContent = parameters.monitorContent or false
    self.containers = {}
    
    modula:registerService(self, "containers")
    modula:registerForEvents(self, "onStart", "onStop", "onSlowUpdate")

    if self.monitorContent then
        modula:registerForEvents(self, "onContentUpdate", "onContentTick")
    end
end

-- ---------------------------------------------------------------------
-- Event handlers
-- ---------------------------------------------------------------------

function Module:onStart()
    debugf("Container Monitor started.")

    self:checkForChanges()
    if self.monitorContent then
        self:requestContainerContent()

        -- timer which periodically asks the container to refresh its contents
        -- (the container API is limited to one call every 30 seconds)
        modula:addTimer("onContentTick", 30.0)
    end
end

function Module:onStop()
    debugf("Container Monitor stopped.")
end

function Module:onContentUpdate()
    self:checkForChanges()
end

function Module:onContentTick()
    self:requestContainerContent()
end

function Module:onSlowUpdate()
    self:checkForChanges()
end


-- ---------------------------------------------------------------------
-- Internal
-- ---------------------------------------------------------------------

function Module:findContainers(...)
    local containers = {}
    for i,class in ipairs({ ... }) do
        modula:withElements(class, function(element)
            table.insert(containers, element)
            debugf("Found container %s", element:name())
        end)
    end
    self.containers = containers
end

function Module:checkForChanges()
    printf("check for changes %s", self)
    for i,container in ipairs(self.containers) do
        printf("blah")
        local element = container.element
        printf("blah")
        local content = element.getContent()
        printf("blah")
        local volume = element.getItemsVolume()
        printf("blah")
        local max = element.getMaxVolume()
        printf("blah")
        local percentage = volume / max 
        printf("blah")
        if container.percentage ~= percentage then
            printf("wibble")
            container.percentage = percentage
            printf("wibble")
            container.volume = volume
            printf("wibble")
            container.max = max
            printf("wibble")
            for k,v in pairs(container) do printf("%s:%s", k,v) end
            printf("calling container changed")
            modula:call("onContainerChanged", container)
        end
    end
end

function Module:requestContainerContent()
    for i,container in ipairs(self.containers) do
        local element = container.element
        element.updateContent()
    end
end

-- updateContent
-- onContentUpdate
-- getMaxVolume
-- getItemsVolume
-- getItemsMass
-- getSelfMass

return Module