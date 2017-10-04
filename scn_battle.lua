----------------
-- References --
----------------

local Camera       = require 'lib_camera'
local SceneManager = require 'scn_scn_manager'
local SceneMenu    = require 'scn_menu'
local Character    = require 'cls_character'
local Player       = require 'cls_player'

local Base = require 'scn_base'
local Scene = {}
setmetatable(Scene, Base)
Scene.__index = Scene

--------------------
-- Initialisation --
--------------------

function Scene.new(scenario, party)
    local this = Base.new("battle")
    setmetatable(this, Scene)
    this.camera = Camera.new()
    this.scenario = scenario
    this.party = party
    return this
end

function Scene:load()
    self.highlight_animation_timer = nil
    self.selected_character = nil
    self.player_characters  = {
        Player.new(4, 6, 0),
        Player.new(7, 2, 1),
    } -- @TODO: get from self.party
    self.enemies = {} -- @TODO: get from scenario
    self.available_actions = {}
    self.current_action = nil
    self:loadMap()
    self:refreshVisibilty()
end

function Scene:loadMap()
    -- @TODO: load data from self.scenario
    self.map = {}
    for j = 1, 10 do
        self.map[j] = {}
        for i = 1, 10 do
            self.map[j][i] = {
                visible  = false,
                passable = true,
            }
        end
    end
end

--------------------------
-- Accessor Methods --
--------------------------

function Scene:isVisible(i, j)
    return self.map[j] and self.map[j][i] and self.map[j][i].visible
end

function Scene:isPassable(i, j)
    return self.map[j] and self.map[j][i] and self.map[j][i].passable
end

--------------------------
-- Manipulation Methods --
--------------------------

function Scene:selectCharacter(char)
    self:cancelCurrentAction()
    self:deselectCharacter()

    self.selected_character = char
    self.highlight_animation_timer = 0
    self:refreshAvailableActions()

    if love.keyboard.isDown("lshift") then -- @TODO: have this not be a magic number
        char:showVisibility()
    end
    if love.keyboard.isDown("/") then -- @TODO: have this not be a magic number
        self:openCharacterInformation(char)
    end
end

function Scene:openCharacterInformation(char)
    -- @TODO: it's nice that this works, but just have a GUI element in this scene
    --        so the background still updates. A new scene just isn't needed.
    local background = love.graphics.newImage(love.graphics.newScreenshot())
    local next_scene = SceneMenu.new(char, background)
    SceneManager.pushScene(next_scene)
end

function Scene:refreshAvailableActions()
    self.available_actions = self.selected_character:getAvailableActions()
end

function Scene:deselectCharacter()
    if self.current_action then
        self:cancelCurrentAction()
    end
    if self.selected_character then
        self.selected_character:hideVisibility()
    end

    self.selected_character = nil
    self.highlight_animation_timer = nil
end

function Scene:selectAction(action)
    self.current_action = action.new(self, self.selected_character)
    self.current_action:load()
end

function Scene:cancelCurrentAction()
    self.current_action = nil
end

function Scene:refreshVisibilty()
    for j, row in pairs(self.map) do
        for i, tile in pairs(row) do
            tile.visible = true -- @TODO: this reveals all
        end
    end
end

--------------------
-- Input Handling --
--------------------

function Scene:keyPressed(key)
    if self.current_action then
        self.current_action:keyPressed(key)
    elseif self.selected_character then
        for _, action in pairs(self.available_actions) do
            if key == action.hotkey then
                self:selectAction(action)
            end
        end
    else
        -- ...?
    end
end

function Scene:mouseReleased(mx, my, key)
    if self.current_action then
        local ignore_other_mouse_effects = self.current_action:mouseReleased(mx, my, key)
        if ignore_other_mouse_effects then
            return
        end
    end
    local wx, wy = self.camera:toWorldPosition(mx, my)
    if key == 1 then
        for i, char in pairs(self.player_characters) do
            -- characters on map
            if char:isMouseOver(wx, wy) then
                self:selectCharacter(char)
            end
            -- character actions
            if self.selected_character == char then
                local x, y = char:getPixelPosition()
                local w, h = 32, 32
                x = x - 36
                y = y + 24
                if wx >= x and wx <= x + w and wy >= y and wy <= y + h then
                    char:toggleVisibility()
                end
                x = x + 36 + 4
                if wx >= x and wx <= x + w and wy >= y and wy <= y + h then
                    self:openCharacterInformation(char)
                end
            end
            -- characters on HUD
            local x = 12
            local y = 72 + (i-1) * 40
            local w = 32
            local h = 32
            if mx >= x and mx <= x + w and my >= y and my <= y + h then
                self:selectCharacter(char)
            end
        end
        for i, char in pairs(self.enemies) do
            if self:isVisible(char:getMapPosition()) and char:isMouseOver(wx, wy) then
                self:selectCharacter(char)
            end
        end
        for i, action in pairs(self.available_actions) do
            local max_actions_across = 2
            local ox = love.graphics.getWidth() - 48
            if #self.available_actions > 1 then ox = ox - 48 end
            local oy = love.graphics.getHeight() - math.ceil(#self.available_actions / 2) * 48
            for n, action in pairs(self.available_actions) do
                local i = (n-1) % max_actions_across
                local j = math.floor((n-1) / max_actions_across)
                local x = ox + i * 48
                local y = oy + j * 48
                local w = 32
                local h = 32
                if mx >= x and mx <= x + w and my >= y and my <= y + h then
                    self:selectAction(action)
                end
            end
        end
    end
    if key == 2 then
        self:deselectCharacter()
    end
end

-----------------------
-- Update Processing --
-----------------------

function Scene:update(dt, mx, my)
    if self.current_action then
        self.current_action:update(dt, mx, my)
    end
    if self.highlight_animation_timer then
        self.highlight_animation_timer = self.highlight_animation_timer + dt
    end
    if love.keyboard.isDown("up") then
        self.camera:move(0, -128 * dt)
    end
    if love.keyboard.isDown("down") then
        self.camera:move(0, 128 * dt)
    end
    if love.keyboard.isDown("left") then
        self.camera:move(-128 * dt, 0)
    end
    if love.keyboard.isDown("right") then
        self.camera:move(128 * dt, 0)
    end
end

---------------------
-- Draw Processing --
---------------------

function Scene:draw()
    self.camera:set()
    self:drawMap()
    self:drawOverlay()
    self.camera:unset()
    self:drawGui()
end

function Scene:drawMap()
    for j, row in pairs(self.map) do
        for i, tile in pairs(row) do
            love.graphics.setColor(255, 64, 64, 64)
            love.graphics.rectangle("line", (i-1) * 32, (j-1) * 32, 32, 32)
            self:drawTile(tile)
        end
    end
    for _, char in pairs(self.player_characters) do
        char:draw()
    end
end

function Scene:drawTile(tile)
    -- tile.visible
    -- tile.tile
end

function Scene:drawOverlay()
    if self.selected_character then
        local x, y = self.selected_character:getPixelPosition()
        love.graphics.setColor(0, 128, 128)
        local r = math.sin(self.highlight_animation_timer * math.pi * 2)
        love.graphics.arc("line", "open", x, y, 16, r, r + math.pi / 2)
        love.graphics.arc("line", "open", x, y, 16, r + math.pi, r + math.pi * 3 / 2)

        love.graphics.setColor(255, 255, 255, 192)
        love.graphics.rectangle("line", x - 36, y + 24, 32, 32, 4, 4)
        -- @TODO: draw action's icon
        love.graphics.printf("vision", x - 36, y + 24, 32, "center")

        love.graphics.rectangle("line", x + 4, y + 24, 32, 32, 4, 4)
        -- @TODO: draw action's icon
        love.graphics.printf("info", x + 4, y + 24, 32, "center")
    end
    if self.current_action then
        self.current_action:drawWorld()
    end
end

function Scene:drawGui()
    -- @TODO: replace with some graphics.
    love.graphics.setColor(255, 255, 255, 192)
    -- draw menu button and level objectives & turn count
    love.graphics.rectangle("line", 6, 6, 160, 56, 8, 8)
        love.graphics.line(12, 12, 66, 12)
        love.graphics.line(12, 32, 66, 32)
            love.graphics.printf("MENU", 16, 16, 48, "center")
        love.graphics.print("Turn 17", 80, 16)
        love.graphics.print("Rescue Linton", 12, 40)
    -- draw all player-controlled characters
    for i, char in pairs(self.player_characters) do
        love.graphics.rectangle("line", 12, 72 + (i-1) * 40, 32, 32, 4, 4)
        -- draw the character
        if char == self.selected_character then
            love.graphics.setColor(0, 255, 255, 128)
            love.graphics.rectangle("line", 11, 71 + (i-1) * 40, 34, 34, 4, 4)
            -- highlight it somehow
            love.graphics.setColor(255, 255, 255, 192)
        end
    end

    if self.selected_character then
        -- draw character portrait and stats
        local function guiStencilFunction()
            love.graphics.circle("fill", love.graphics.getWidth() - 54, 54, 48)
        end
        love.graphics.setColor(255, 255, 255, 192)
        love.graphics.circle("line", love.graphics.getWidth() - 54, 54, 48)
        love.graphics.stencil(guiStencilFunction, "increment")
        love.graphics.setStencilTest("less", 1)
        love.graphics.rectangle("line", love.graphics.getWidth() - 256, 54 - 32, 256 - 48, 64, 8, 8)
        love.graphics.setStencilTest()
        -- draw options (check vision & view stats/inventory)
        -- draw actions (context-dependent)
        local max_actions_across = 2
        local actions = self.available_actions
        local ox = love.graphics.getWidth() - 48
        if #actions > 1 then ox = ox - 48 end
        local oy = love.graphics.getHeight() - math.ceil(#actions / 2) * 48
        for n, action in pairs(actions) do
            local i = (n-1) % max_actions_across
            local j = math.floor((n-1) / max_actions_across)
            local x = ox + i * 48
            local y = oy + j * 48
            love.graphics.setColor(255, 255, 255, 192)
            love.graphics.rectangle("line", x, y, 32, 32, 4, 4)
            -- @TODO: draw action's icon
            -- @TODO: draw action's text as a tooltip on hover? touch devices don't have hover...
            love.graphics.printf(action.text, x, y, 32, "center")
            if self.current_action and getmetatable(self.current_action) == action then
                love.graphics.setColor(0, 255, 255, 128)
                love.graphics.rectangle("line", x - 1, y - 1, 34, 34, 4, 4)
            end
        end
    end
    if self.current_action then
        self.current_action:drawScreen()
    end
end

return Scene
