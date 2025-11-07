--========================================================--
--  MAIN.LUA
--  Entry point of the Wisp architecture.
--  Initializes the root Wisp and delegates update, draw,
--  and input handling through its hierarchy.
--========================================================--

-- Initialize debugger if running in VS Code
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local Root = require("system.root")

------------------------------------------------------------
-- Initialization
------------------------------------------------------------
function love.load()
    love.window.setMode(800, 600)
    love.window.setTitle("Wisp Architecture")
    root = Root:new()
end

------------------------------------------------------------
-- Update loop
------------------------------------------------------------
function love.update(dt)
    root:update()
end

------------------------------------------------------------
-- Draw loop
------------------------------------------------------------
function love.draw()
    root:draw()
end

------------------------------------------------------------
-- Input handling
-- Delegates all key events to root wisp hierarchy
------------------------------------------------------------
function love.keypressed(key)
    root:handle_input("keypressed", key)
end

function love.keyreleased(key)
    root:handle_input("keyreleased", key)
end
