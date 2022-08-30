
require('api')

local Layer = require('samedicorp.modula.toolkit.layer')
local Render = require('samedicorp.modula.render')


function love.draw()
    local layer = Layer.new()
    love.graphics.print("Hello World!", 100, 100)
end