local UILibrary = {}

-- Setup sub-tables/classes
local UILibNames = {
    "Window",
    "Category",
    "Button",
    "Section"
}

for i, v in pairs(UILibNames) do
    UILibrary[v] = {}
    UILibrary[v].__index = UILibrary[v]
end

-- Initialize TweenInfo dynamically shared across modules
UILibrary.TweenInfo = TweenInfo.new(.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

-- Registry of service-level connections (UserInputService, RunService, ...)
-- that would otherwise outlive the GUI; Window:Unload disconnects them all
UILibrary._connections = {}
UILibrary.trackConnection = function(conn)
    table.insert(UILibrary._connections, conn)
    return conn
end

-- Require and initialize all modular method extensions
require(script.window)(UILibrary)
require(script.category)(UILibrary)
require(script.button)(UILibrary)
require(script.section)(UILibrary)

return UILibrary
