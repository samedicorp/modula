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

    self.output = ""
    system.print = function(text)
        self.output = string.format("%s%s\n", self.output, text)
    end


    _G.unit = makeMock("ControlUnit", 2, "programming board")
end

function TestSuite:tearDown()
    -- print(self.output)
    self.output = ""
end

function TestSuite:makeModula(settings)
    local library, player, construct
    self.modula = modulaPrototype.new(system, library, player, construct, unit, settings)
    return self.modula
end

function TestSuite:testCoreLifecycle()
    local modula = self:makeModula({
        logging = true,
        logCalls = true
    })

    luaunit.assert_nil(modula:call("onStart"))
    luaunit.assert_nil(modula:call("onStop"))
    luaunit.assert_str_contains(self.output, "calling onStart")
    luaunit.assert_str_contains(self.output, "calling onStop")
end

function TestSuite:testPanels()
    local modula = self:makeModula({
        logging = true,
        useLocal = true,
        modules = {
            ["modules.panels"] = {}
        }
    })

    luaunit.assert_nil(modula:call("onStart"))
    luaunit.assert_nil(modula:call("onStop"))
    luaunit.assert_str_contains(self.output, "Panel manager running.")
    luaunit.assert_str_contains(self.output, "Panel manager stopped")
end

local lu = luaunit.LuaUnit.new()
os.exit( lu:runSuite() )