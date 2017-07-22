local available_resolutions = love.window.getFullscreenModes()
table.sort(available_resolutions, function(a, b) return a.width*a.height < b.width*b.height end)

local Base     = require 'scn_base'
local Dropdown = require 'gui_dropdown'

local Scene = {}
setmetatable(Scene, Base)
Scene.__index = Scene

function Scene.new()
    local this = Base.new("settings")
    setmetatable(this, Scene)
    return this
end

function Scene:load()
    local resolution_iterator = function()
        local i = 0
        return function()
            i = i + 1
            if available_resolutions[i] == nil then return nil end
            return {
                text = available_resolutions[i].width .. "x" .. available_resolutions[i].height,
                value = { available_resolutions[i].width, available_resolutions[i].height},
            }
        end
    end
    self.gui = {
        Dropdown.new({
            position = {64, 64},
            size     = {128, 32},
            populate = resolution_iterator,
        })
    }
end

function Scene:draw()
    for _, element in pairs(self.gui) do
        element:draw()
    end
end

return Scene