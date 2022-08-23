package.path = package.path .. ";./du-mocks/src/?.lua"

luaunit = require('luaunit')
mockCoreUnit = require("dumocks.CoreUnit")
mockControlUnit = require("dumocks.ControlUnit")
mockSystem = require("dumocks.System")
modulaPrototype = require('core')

TestSuite = {}

function TestSuite:setUp()
    local coreMock = mockCoreUnit:new(nil, 1, "dynamic core unit s")
    coreMock.constructName = "My Construct"
    _G.Unit_MockCore = coreMock:mockGetClosure()

    _G.system = mockSystem:new()
    system.print = print

    local unitMock = mockControlUnit:new(nil, 2, "programming board")
    _G.unit = unitMock:mockGetClosure()
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