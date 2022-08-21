require('lfs')

local root = arg[1]

local source = {}
local modules = {}

require("configure")
local config = modulaSettings

function lastPathComponent(path)
    local items = path:split('/')
    return items[#items]
  end
  
  function name(path)
    return lastPathComponent:split(last)
  end

function load(path)
    local f = io.open(path, 'r')
    local t = ""
    if f then
      t = f:read("*all")
      f:close()
    end
    return t
end

function save(path, text, mode)
    local f = io.open(path, mode or 'w')
    if f then
      f:write(text)
      f:close()
    end
end

function iterateFiles(path, action)
    for file in lfs.dir(path) do
      if not ((file == '.') or (file == '..')) then
        local index = file:find("[.]") or #file
        local name = file:sub(1, index - 1)
        local extension = file:sub(index)
        action(name, extension, path .. "/" .. file)
      end
    end
  end

function appendSource(path, name)
    local code = "\n" .. load(path)
    local stripped = code:gsub("%-%- .-\n", "\n")
    table.insert(source, string.format("function MODULE_%s()\n", name))
    table.insert(source, stripped)
    table.insert(source, string.format("end -- MODULE_%s\n", name))
end

function scanModules(root, path, prefix, modules)
    for name, parameters in pairs(modules) do
        local path = root .. name:gsub("[.]", "/") .. ".lua"
        local safeName = name:gsub("[.-]", "_")

        local paramitems = {}
        for k, v in pairs(parameters) do
            table.insert(paramitems, string.format("%s = \"%s\"", k, v))
        end

        local paramstr = ""
        if #paramitems > 0 then
            paramstr = string.format(", { %s }", table.concat(paramitems, ","))
        end

        appendSource(path, safeName)
    end
end

function jsonEscaped(string)
    return string:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\"")
end

function indented(string, indent)
    return string:gsub("\n", "\n" .. indent)
end

source = {}

appendSource(root .. "samedicorp/modula/core.lua", "core")
scanModules(root, "samedicorp", "", config.modules)

local configSource = load("configure.lua")
local configEscaped = jsonEscaped(configSource)
local configIndented = indented(configSource, "        ")

local moduleSource = table.concat(source, "\n")
local moduleEscaped = jsonEscaped(moduleSource)
local moduleIndented = indented(moduleSource, "        ")

local outputPath = root .. "autoconf/custom/"
-- local luaPath = outputPath .. config.name .. ".lua"
-- local luaTemplate = load(root .. "samedicorp/modula/templates/packed.lua")
-- save(luaPath, string.format(luaTemplate, moduleSource, configSource))

local jsonPath = outputPath .. config.name .. ".json"
local jsonTemplate = load(root .. "samedicorp/modula/templates/packed.json")
save(jsonPath, string.format(jsonTemplate, configEscaped, config.name, moduleEscaped))

local confPath = outputPath .. config.name .. ".conf"
local confTemplate = load(root .. "samedicorp/modula/templates/packed.conf")
save(confPath, string.format(confTemplate, config.name, configIndented, moduleIndented))

print("Done.")

-- TODO
-- Make config a dictionary.
-- Pass config name or dictionary to core controller.
-- Store modules in global so that handlers can access them with `modules.panels.xx` etc.
