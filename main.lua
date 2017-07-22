local tlo = require 'lib_tlo'
T = tlo.localise

local SceneManager = require 'scn_scn_manager'
local InitialScene = require 'scn_battle'

local function createDefaultSettings()
    local settings_file = love.filesystem.newFile("settings")
    settings_file:open('w')
    settings_file:write("return {\n")
    settings_file:write("    graphics = {\n")
    settings_file:write("        resolution = { 640, 480 },\n")
    settings_file:write("        vsync = true,\n")
    settings_file:write("        fullscreen = 0,\n")
    -- @TODO: add colour blind settings

    settings_file:write("    },\n")
    settings_file:write("    language = \"en-UK\",\n")
    settings_file:write("}\n")
    settings_file:close()
    
    love.filesystem.createDirectory("lang")
    local default_language_file = love.filesystem.newFile("lang/en-UK")
    default_language_file:open("w")
    default_language_file:write("return {}")
    default_language_file:close()
end

local function applySettings()
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setLineStyle("rough")

    if not love.filesystem.exists("settings") then
        createDefaultSettings()
    end
    tlo.setLanguagesFolder("lang")

    local settings = love.filesystem.load("settings")()
    if settings.graphics then
        local width  = settings.graphics.resolution[1] or 800
        local height = settings.graphics.resolution[2] or 600
        local flags = {}
        flags.vsync = settings.graphics.vsync == 1
        local fullscreen = settings.graphics.fullscreen or 0
        flags.fullscreen = fullscreen > 0
        flags.fullscreentype = ({"desktop", "exclusive"})[fullscreen]
        love.window.setMode(width, height, flags)
    end
    
    if settings.language then
        tlo.setLanguage(settings.language)
    end
end

function love.load()
    applySettings()
    local scene = InitialScene.new(nil, {})
    SceneManager.setScene(scene)
end

function love.keypressed(key, isRepeat)
    SceneManager.scene():keyPressed(key, isRepeat)
end

function love.keyreleased(key)
    SceneManager.scene():keyReleased(key)
end 

function love.textinput(text)
    SceneManager.scene():keyTyped(text)
end

function love.mousepressed(mx, my, key)
    SceneManager.scene():mousePressed(mx, my, key)
end

function love.mousereleased(mx, my, key)
    SceneManager.scene():mouseReleased(mx, my, key)
end

function love.wheelscrolled(dx, dy)
    local mx, my = love.mouse.getPosition()
    SceneManager.scene():mouseScrolled(mx, my, dx, dy)
end

function love.update(dt)
    local mx, my = love.mouse.getPosition()
    SceneManager.scene():update(dt, mx, my)
end

function love.draw()
    SceneManager.scene():draw()
end