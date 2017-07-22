local Action = {}
Action.__index = Action

--------------------
-- Initialisation --
--------------------

function Action.new(scene, character)
    local this = {}
    setmetatable(this, Action)
    this.scene     = scene
    this.character = character
    return this
end

function Action:load()
    -- stub
end

function Action:close()
    self.scene:cancelCurrentAction()
end

--------------------
-- Input Handling --
--------------------

function Action:mouseReleased(mx, my, key)
    -- stub
end

function Action:keyPressed(key)
    -- stub
end

-----------------------
-- Update Processing --
-----------------------

function Action:update(dt, mx, my)
    -- stub
end

---------------------
-- Draw Processing --
---------------------

function Action:drawWorld()
    -- stub
end

function Action:drawScreen()
    -- stub
end

return Action