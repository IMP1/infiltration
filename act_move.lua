local BaseAction = require 'act_base'

local MoveAction = {
    text   = "Move",
    hotkey = "m"
}
setmetatable(MoveAction, BaseAction)
MoveAction.__index = MoveAction

--------------------
-- Initialisation --
--------------------

function MoveAction.new(scene, character)
    local this = BaseAction.new(scene, character)
    setmetatable(this, MoveAction)
    return this
end

function MoveAction:load()
    self.available_moves = self:getCharacterMoves()
end

--------------------------
-- Accessor Methods --
--------------------------

local function getAvailableMoves(move_list, i, j, map, moves_remaining)
    if moves_remaining < 1 then
        return
    end
    if map[j] and map[j][i] and map[j][i].passable then
        if not move_list[j] then
            move_list[j] = {}
        end
        if not move_list[j-1] then
            move_list[j-1] = {}
        end
        if not move_list[j+1] then
            move_list[j+1] = {}
        end

        if not move_list[j][i] or move_list[j][i] < moves_remaining then
            move_list[j][i] = moves_remaining
        end

        if move_list[j - 1][i] == nil or move_list[j - 1][i] < moves_remaining - 1 then
            getAvailableMoves(move_list, i, j - 1, map, moves_remaining - 1)
        end
        if move_list[j][i - 1] == nil or move_list[j][i - 1] < moves_remaining - 1 then
            getAvailableMoves(move_list, i - 1, j, map, moves_remaining - 1)
        end
        if move_list[j + 1][i] == nil or move_list[j + 1][i] < moves_remaining - 1 then
            getAvailableMoves(move_list, i, j + 1, map, moves_remaining - 1)
        end
        if move_list[j][i + 1] == nil or move_list[j][i + 1] < moves_remaining - 1 then
            getAvailableMoves(move_list, i + 1, j, map, moves_remaining - 1)
        end
    end
end

function MoveAction:getCharacterMoves()
    local moves = {}
    local i, j = self.character:getMapPosition()
    local move_count = self.character.action_points * self.character.stats.speed / 10
    print("move count:", move_count)

    getAvailableMoves(moves, i, j - 1, self.scene.map, move_count)
    getAvailableMoves(moves, i - 1, j, self.scene.map, move_count)
    getAvailableMoves(moves, i, j + 1, self.scene.map, move_count)
    getAvailableMoves(moves, i + 1, j, self.scene.map, move_count)

    return moves
end

--------------------
-- Input Handling --
--------------------

function MoveAction:keyPressed(key)
    if key == "escape" then
        self:close()
    end
    -- @TODO: fill out
end

function MoveAction:mouseReleased(mx, my, key)
    local wx, wy = self.scene.camera:toWorldPosition(mx, my)
    local i = math.floor(wx / 32) + 1
    local j = math.floor(wy / 32) + 1
    print(i, j)
    if self.available_moves[j] and self.available_moves[j][i] and self.available_moves[j][i] > 0 then
        print(self.available_moves[j][i])
    end
    -- @TODO: fill out
end

-----------------------
-- Update Processing --
-----------------------

function MoveAction:update(dt, mx, my)
    -- @TODO: fill out
end

---------------------
-- Draw Processing --
---------------------

function MoveAction:drawWorld()
    love.graphics.setColor(0, 0, 255, 32)
    for j, row in pairs(self.available_moves) do
        for i, cost in pairs(row) do
            local x, y = (i-1) * 32, (j-1) * 32
            love.graphics.rectangle("fill", x, y, 32, 32)
            love.graphics.print(tostring(cost), x, y) -- @TODO: remove this
        end
    end
end

return MoveAction