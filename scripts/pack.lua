require('lfs')
require("configure")

local root = arg[1]
local source = {}
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

function appendSource(path, name)
  print(string.format("Loaded %s.", name))
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

function writeTemplate(format, ...)
  local path = string.format("%sautoconf/custom/%s.%s", root, config.name, format)
  local template = load(string.format("%ssamedicorp/modula/templates/packed.%s", root, format))
  save(path, string.format(template, ...))
  print(string.format("Exported %s.%s", config.name, format))

  return path
end


print(string.format("Building %s", config.name))
appendSource(root .. "samedicorp/modula/core.lua", "core")
scanModules(root, "samedicorp", "", config.modules)

local configSource = load("configure.lua")
local configEscaped = jsonEscaped(configSource)
local configIndented = indented(configSource, "        ")

local moduleSource = table.concat(source, "\n")
local moduleEscaped = jsonEscaped(moduleSource)
local moduleIndented = indented(moduleSource, "        ")

-- writeTemplate("lua", moduleSource, configSource)
local jsonPath = writeTemplate("json", configEscaped, config.name, moduleEscaped)
writeTemplate("conf", config.name, configIndented, moduleIndented)

-- copy the generated json to the clipboard
local command = string.format('clip.exe < "%s"', jsonPath)
os.execute(command)

print("Done.")



