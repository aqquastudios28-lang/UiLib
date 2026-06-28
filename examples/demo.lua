-- examples/demo.lua
-- Complete Premium Showcase of QwenUILib v2.0.0
-- Beautiful Obsidian Dark Glass UI with Liquid Neon effects

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourName/QwenUILib/main/build/bundle.lua"))()

-- Initial Load Notification
Library:Notify({
    Title = "QwenUILib Loaded",
    Content = "Injecting premium liquid glass theme...",
    Duration = 4,
    Image = "⚡"
})

-- Create main window
local Window = Library:CreateWindow({
    Name = "QwenUI Premium v2.0",
    Size = UDim2.new(0, 620, 0, 460),
    ToggleKey = Enum.KeyCode.RightShift
})

-- =========================================
-- CATEGORY: COMBAT (Tab Group)
-- =========================================
local CombatGroup = Window:CreateTabGroup("Combat")

-- Tab: Aimbot (using Subtabs)
local AimbotTab = CombatGroup:CreateTab("Aimbot", "🎯")
local MainAimSub = AimbotTab:CreateSubTab("Main Settings")
local VisualAimSub = AimbotTab:CreateSubTab("Draw FOV")

-- Main Settings Subtab
MainAimSub:CreateToggle("Aimbot Enabled", false, function(state)
    print("Aimbot status:", state)
    Window:Notify({
        Title = "Aimbot Toggle",
        Content = state and "Aimbot is now ACTIVE." or "Aimbot is now INACTIVE.",
        Duration = 3,
        Image = state and "🟢" or "🔴"
    })
end)

MainAimSub:CreateSlider("Aimbot Smoothness", 1, 20, 5, function(value)
    print("Aimbot Smoothness:", value)
end)

MainAimSub:CreateDropdown("Hitbox Priority", {"Head", "Torso", "Random"}, "Head", function(target)
    print("Hitbox Target:", target)
end)

-- Visual Aim Subtab
VisualAimSub:CreateToggle("Show FOV Circle", false, function(state)
    print("FOV Circle Visible:", state)
end)

VisualAimSub:CreateColorPicker("FOV Circle Color", Color3.fromRGB(0, 180, 255), function(color)
    print("FOV Color changed:", color)
end)

VisualAimSub:CreateSlider("FOV Circle Radius", 30, 300, 100, function(value)
    print("FOV Radius:", value)
end)


-- =========================================
-- CATEGORY: VISUALS
-- =========================================
local VisualsGroup = Window:CreateTabGroup("Visuals")

local EspTab = VisualsGroup:CreateTab("ESP Settings", "👁️")
local EspSection = EspTab:CreateSection("ESP Options")

EspSection:CreateToggle("Enable ESP", false, function(state)
    print("ESP Active:", state)
end)

EspSection:CreateMultiDropdown("ESP Details", {"Boxes", "Names", "Tracers", "Healthbars", "Chams"}, {"Boxes", "Names"}, function(selectedList)
    print("Active ESP layers:", table.concat(selectedList, ", "))
end)

EspSection:CreateColorPicker("ESP Overlay Color", Color3.fromRGB(255, 0, 150), function(color)
    print("ESP Color changed:", color)
end)


-- =========================================
-- CATEGORY: UTILITIES
-- =========================================
local UtilsGroup = Window:CreateTabGroup("Utilities")

local UtilitiesTab = UtilsGroup:CreateTab("Logs & Actions", "🛠️")

-- Console Component for logging events in-game
local Console = UtilitiesTab:CreateConsole("Action Console")

Console:Log("Console initialized successfully.", "success")
Console:Log("Welcome to QwenUILib premium console environment.", "info")

UtilitiesTab:CreateButton("Trigger Test Log", function()
    local logTypes = {"info", "warn", "error", "success"}
    local chosenType = logTypes[math.random(1, #logTypes)]
    Console:Log("This is a random test log entry of type: " .. chosenType, chosenType)
end)

UtilitiesTab:CreateButton("Clear Logs", function()
    Console:Clear()
    Console:Log("Console logs cleared by user.", "warn")
end)


-- =========================================
-- CATEGORY: CONFIGS & HELP
-- =========================================
local SettingsGroup = Window:CreateTabGroup("Settings")

-- Tab: Info (displays Label & Paragraph components)
local InfoTab = SettingsGroup:CreateTab("Information", "ℹ️")

InfoTab:CreateLabel("QwenUILib - The Ultimate UI Framework", Enum.TextXAlignment.Center)

InfoTab:CreateParagraph("Liquid Glass Aesthetic", 
    "This library utilizes layered gradients, custom radial blur drops, and fine edge highlight strokes to simulate glass reflection. The animated background features floating neon circles, adding depth and fluid transitions directly inside your Roblox client.")

InfoTab:CreateParagraph("Credits", "Developed and upgraded with precision by Antigravity and QwenUI. Enjoy the smoothest UI experience on Roblox executors.")

-- Tab: Settings
local SettingsTab = SettingsGroup:CreateTab("Configuration", "⚙️")

SettingsTab:CreateKeybind("Toggle UI Keybind", Enum.KeyCode.RightShift, function(key)
    print("Menu toggle bind changed to:", key)
    Window.ToggleKey = key
    Window:Notify({
        Title = "Keybind Changed",
        Content = "Menu toggle is now bound to " .. tostring(key.Name or key),
        Duration = 3,
        Image = "⌨️"
    })
end)

SettingsTab:CreateTextbox("Config Name", "Enter name...", "DefaultConfig", function(text)
    print("Current configuration title:", text)
end)

SettingsTab:CreateButton("Save Settings", function()
    Window:Notify({
        Title = "Config Saved",
        Content = "Configuration has been saved to workspace/QwenUI/configs!",
        Duration = 3.5,
        Image = "💾"
    })
end)

SettingsTab:CreateButton("Destroy Library UI", function()
    Window.ScreenGui:Destroy()
    Library:Notify({
        Title = "Unloaded",
        Content = "GUI completely destroyed and memory released.",
        Duration = 3,
        Image = "🗑️"
    })
end)