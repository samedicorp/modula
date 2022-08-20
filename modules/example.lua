-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 31/10/2020.
--  All code (c) 2020 - present day, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local ExampleModule = {
    class = "ExampleModule"
}

function ExampleModule.new(core, parameters)
    parameters = parameters or {}
    local instance = { 
        _core = core
     }

     setmetatable(instance, { __index = ExampleModule })
    return instance
end

function ExampleModule:register()
    debug("registered")
end

return ExampleModule