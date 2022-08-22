luaunit = require('luaunit')

function error(format, ...)
    print("ERROR: %s", format:format(...))
    luaunit.assertTrue(false)
end

system = {
    print = print
}

function test_core()
    local library, player, construct, unit
    local settings = {}
    local prototype = require('core')
    local core = prototype.new(system, library, player, construct, unit, settings)
    core:call("onStart")
end

local lu = luaunit.LuaUnit.new()
os.exit( lu:runSuite() )