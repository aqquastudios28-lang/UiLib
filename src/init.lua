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

-- Require and initialize all modular method extensions
require(script.window)(UILibrary)
require(script.category)(UILibrary)
require(script.button)(UILibrary)
require(script.section)(UILibrary)

return UILibrary
