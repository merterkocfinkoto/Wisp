--========================================================--
--  WISP CLASS
--  Base entity framework for hierarchical, autonomous units
--========================================================--

local Wisp = {}
Wisp.__index = Wisp

------------------------------------------------------------
-- Constructor
------------------------------------------------------------
function Wisp:new(name, context)
    local w = setmetatable({}, self)
    math.randomseed(os.clock() * 1e9)
    w.id = tostring(math.random(1e9))
    w.name = name or ""
    w.context = context
    w.content = {}
    w.properties = {}
    w.state = "idle"
    w.processes = {}
    w.appearance = function() end
    w.attended = false
    w.controls = {}
    if not w:check_context() then
        error("Invalid context for wisp '" .. (w.name or "?") .. "'")
    end
    return w
end

------------------------------------------------------------
-- Context validation (override in subclasses if needed)
------------------------------------------------------------
function Wisp:check_context()
    return true
end

------------------------------------------------------------
-- Get class type
------------------------------------------------------------
function Wisp:type()
    return getmetatable(self)
end

------------------------------------------------------------
-- List instance-only methods
------------------------------------------------------------
function Wisp:list_instance_methods()
    local methods, class = {}, getmetatable(self)
    for k, v in pairs(self) do
        if type(v) == "function" and type(class[k]) ~= "function" then
            methods[#methods + 1] = k
        end
    end
    return methods
end

------------------------------------------------------------
-- Add / Get sub-wisps
------------------------------------------------------------
function Wisp:add_wisp(entity)
    if not entity.name or entity.name == "" then error("Unnamed wisp.") end
    if self.content[entity.name] then error("Duplicate wisp: " .. entity.name) end
    entity.context = self
    self.content[entity.name] = entity
end

function Wisp:get_wisp(name)
    return self.content[name]
end

------------------------------------------------------------
-- Activate deactivate methods
------------------------------------------------------------
function Wisp:activate(method)
    assert(type(method) == "string", "activate: method name must be a string")
    self.processes[method] = true
end

function Wisp:deactivate(method)
    assert(type(method) == "string", "activate: method name must be a string")
    self.processes[method] = nil
end


------------------------------------------------------------
-- Controls 
------------------------------------------------------------
function Wisp:add_control(args)
    assert(args.action and args.mode and args.event and args.key,
        "add_control: missing required field (action, mode, event, key)")
    
    local a, m = args.action, args.mode
    self.controls[a] = self.controls[a] or {}
    self.controls[a][m] = {
        event = args.event or false,
        key = args.key or false,
        requires_attend   = args.requires_attend   or false,
        requires_active   = args.requires_active   or false,
        requires_deactive = args.requires_deactive or false
    }
end



function Wisp:remove_control(action, mode)
    if not self.controls[action] then return end
    if mode then
        self.controls[action][mode] = nil
        if next(self.controls[action]) == nil then
            self.controls[action] = nil
        end
    else
        self.controls[action] = nil
    end
end


function Wisp:update_control(args)
    assert(args.action and args.mode, "update_control: missing 'action' or 'mode'")
    local a, m = args.action, args.mode
    if self.controls[a] and self.controls[a][m] then
        local c = self.controls[a][m]
        c.event = args.event or c.event
        c.key = args.key or c.key
        c.requires_attend   = (args.requires_attend   == nil) and c.requires_attend   or args.requires_attend
        c.requires_active   = (args.requires_active   == nil) and c.requires_active   or args.requires_active
        c.requires_deactive = (args.requires_deactive == nil) and c.requires_deactive or args.requires_deactive
    end
end

------------------------------------------------------------
-- Update & Draw
------------------------------------------------------------
function Wisp:update()
    for name in pairs(self.processes) do
        self[name](self)
    end
    for _, w in pairs(self.content) do
        if w.update then w:update() end
    end
end


function Wisp:draw()
    self:appearance()
    for _, w in pairs(self.content) do
        if w.draw then w:draw() end
    end
end

------------------------------------------------------------
-- Attendance
------------------------------------------------------------
function Wisp:attend(state)
    self.attended = (state == nil) and not self.attended or not not state
end

------------------------------------------------------------
-- Recursive input handling
------------------------------------------------------------
function Wisp:handle_input(event, key)
    for action, modes in pairs(self.controls) do
        for mode, c in pairs(modes) do
            if c.event == event and c.key == key
               and ((not c.requires_attend) or self.attended)
               and ((not c.requires_active) or self.processes[action])
               and ((not c.requires_deactive) or not self.processes[action]) then

                if mode == "fire" then self[action](self)
                elseif mode == "activate" then self.processes[action] = true
                elseif mode == "deactivate" then self.processes[action] = nil
                end
            end
        end
    end
    for _, sub in pairs(self.content) do
        if sub.handle_input then sub:handle_input(event, key) end
    end
end


return Wisp
