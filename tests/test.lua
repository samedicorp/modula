package.path = package.path .. ";./du-mocks/src/?.lua"

luaunit = require('luaunit')
mockSystem = require("dumocks.System")
modulaPrototype = require('core')

TestSuite = {}

function makeMock(class, id, name, setup)
    local module = require("dumocks." .. class)
    local mock = module:new(nil, id, name)
    if setup then
        setup(mock)
    end
    return mock:mockGetClosure()
end

function TestSuite:setUp()
    _G.Unit_MockCore = makeMock("CoreUnit", 1, "dynamic core unit s", function(mock)
        mock.constructName = "My Construct"
    end)

    _G.system = mockSystem:new()
    system.print = print

    _G.unit = makeMock("ControlUnit", 2, "programming board")
end

function TestSuite:makeModula(settings)
    local library, player, construct
    self.modula = modulaPrototype.new(system, library, player, construct, unit, settings)
    return self.modula
end

function TestSuite:testCore()
    local modula = self:makeModula({
        logging = true,
        logCalls = true
    })

    modula:call("onStart")
end

function error(format, ...)
    print("ERROR: %s", format:format(...))
    luaunit.assertTrue(false)
end

local lu = luaunit.LuaUnit.new()
os.exit( lu:runSuite() )