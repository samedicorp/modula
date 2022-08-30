
require('api')

local Layer = require('samedicorp.toolkit.layer')
local Render = require('samedicorp.toolkit')


function love.draw()
    local layer = Layer.new()
    love.graphics.print("Hello World!", 100, 100)
end