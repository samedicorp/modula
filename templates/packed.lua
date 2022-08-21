%s

%s

local logging = true --export: Enable controller debug output.
local logElements = false --export: Log all discovered elements.

controller = MODULE_coreController().new(system, unit, library, { logging = logging, logElements = logElements })
controller:run(MODULE_config())
