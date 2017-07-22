local BaseAction = require 'act_base'

local Deselection = {
    text   = "Deselect",
    hotkey = "escape",
}
setmetatable(Deselection, BaseAction)
Deselection.__index = Deselection

--------------------
-- Initialisation --
--------------------

function Deselection.new(scene, character)
    local this = BaseAction.new(scene, character)
    setmetatable(this, Deselection)
    return this
end

function Deselection:load()
    self.scene:deselectCharacter()
    self:close()
end

return Deselection