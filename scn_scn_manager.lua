local SceneManager = {}

local current_scene = nil
local scene_stack = {}

local function closeScene()
    if current_scene then
        current_scene:close()
    end
end

local function loadScene()
    if current_scene then
        current_scene:load()
    end
end

function SceneManager.scene()
    return current_scene
end

function SceneManager.setScene(newScene)
    closeScene()
    current_scene = newScene
    loadScene()
end

function SceneManager.pushScene(newScene)
    table.insert(scene_stack, current_scene)
    current_scene = newScene
    loadScene()
end

function SceneManager.popScene()
    closeScene()
    current_scene = table.remove(scene_stack)
end

return SceneManager