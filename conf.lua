--========================================================--
--  CONF.LUA
--  LÖVE configuration file
--  Ensures proper debugger communication
--========================================================--

function love.conf(t)
    t.console = false  -- Required for debugger communication
    t.window.title = "Wisp Architecture"
    t.window.width = 1280   
    t.window.height = 720
end