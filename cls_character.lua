----------------
-- References --
----------------
local MoveAction     = require 'act_move'
local DeselectAction = require 'act_deselect'

local Character = {}
Character.__index = Character

---------------
-- Constants --
---------------
Character.actions = {
    MOVE     = MoveAction,
    DESELECT = DeselectAction,
}

--------------------
-- Initialisation --
--------------------

function Character.new(x, y, r, stats)
    local this = {}
    setmetatable(this, Character)
    this.position      = { x, y }
    this.direction     = r
    this.stats         = stats or {
        health        = 100,
        action_points = 10,
        speed         = 5, -- 10 * movement-squares / action-points
        vision_range  = 1, -- movement-squares
        vision_spread = 1,
        reflexes      = 1,
        proficiencies = {},
    }
    this.health        = this.stats.health
    this.action_points = this.stats.action_points
    this.equipment     = {}
    return this
end

--------------------------
-- Accessor Methods --
--------------------------

function Character:getMapPosition()
    local x, y = unpack(self.position)
    return x, y
end

function Character:getPixelPosition()
    local i, j = self:getMapPosition()
    return (i - 0.5) * 32, (j - 0.5) * 32
end

function Character:getAvailableActions()
    return { Character.actions.DESELECT }
end

function Character:isMouseOver(mx, my)
    if mx == nil then
        mx, my = love.mouse.getMapPosition()
    end
    local x, y = self:getPixelPosition()
    return (mx - x) ^ 2 + (my - y) ^ 2 <= 16 ^ 2
end

--------------------------
-- Manipulation Methods --
--------------------------

function Character:showVisibility()
    self.show_visibility = true
end

function Character:hideVisibility()
    self.show_visibility = false
end

function Character:toggleVisibility()
    self.show_visibility = not self.show_visibility
end

---------------------
-- Draw Processing --
---------------------

function Character:draw()
    -- stub
    -- @TODO: have this draw the character's image/quad/etc.
    if self.show_visibility then
        self:drawVisibility()
    end
end

function Character:drawVisibility()
    local i, j = self:getMapPosition()
    local r = self.direction * math.pi * 2 / 8
    love.graphics.setColor(0, 255, 128, 128)
    for n = 1, 4 do
        local x = (i - 1) + n * math.floor(math.cos(r) * 1.5)
        local y = (j - 1) + n * math.floor(math.sin(r) * 1.5)
        love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)
    end
end

return Character