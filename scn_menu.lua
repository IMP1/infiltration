----------------
-- References --
----------------

local SceneManager = require 'scn_scn_manager'
local Character    = require 'cls_character'
local Player       = require 'cls_player'

local Base = require 'scn_base'
local Scene = {}
setmetatable(Scene, Base)
Scene.__index = Scene

--------------------
-- Initialisation --
--------------------

function Scene.new(character, background_image)
    local this = Base.new("battle")
    setmetatable(this, Scene)
    this.character = character
    this.background_image = background_image
    return this
end

function Scene:keyPressed(key)
    SceneManager.popScene()
end

function Scene:mouseReleased()
    SceneManager.popScene()
end

function Scene:draw()
    love.graphics.setColor(255, 192, 192)
    love.graphics.draw(self.background_image, 0, 0)
end

return Scene