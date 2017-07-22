function love.conf(g)
    g.version  = "0.10.2"
    g.identity = "infiltration" -- @TODO: change to game name

    g.window.title  = "Untitled"
--     g.window.icon = nil                 -- Filepath to an image to use as the window's icon (string)
    g.window.width  = 640
    g.window.height = 480

    g.modules.physics = false
    g.modules.video   = false
    g.modules.math    = false
    g.modules.thread  = false
end
