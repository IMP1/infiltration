local Character = require 'cls_character'

local Player = {}
setmetatable(Player, Character)
Player.__index = Player

function Player.new(x, y, stats, growth)
    local this = Character.new(x, y, stats)
    setmetatable(this, Player)
    this.growth     = growth
    this.experience = 0
    this.level      = 1
    return this
end

--------------------------
-- Accessor Methods --
--------------------------

-- @Override
function Player:getAvailableActions()
    local actions = Character.getAvailableActions(self)
    if self.action_points * self.stats.speed / 10 > 0 then
        table.insert(actions, 1, Character.actions.MOVE)
    end
    return actions
end

---------------------
-- Draw Processing --
---------------------

-- @Override
function Player:draw()
    local x, y = self:getPixelPosition()
    local r = self.direction * math.pi * 2 / 8
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", x, y, 10)
    love.graphics.line(x, y, x + math.cos(r) * 14, y + math.sin(r) * 14)
    if self.show_visibility then
        self:drawVisibility()
    end
end

return Player