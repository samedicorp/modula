-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
--  Created by Samedi on 20/08/2022.
--  All code (c) 2022, The Samedi Corporation.
-- -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

local Module = { }

function Module:register(modula, parameters)
    modula:registerForEvents({"onStart", "onStop"}, self)
end

function Module:onStart()
    debug("Test module was started")
end

function Module:onStop()
    debug("Test module was stopped")
end

return Module