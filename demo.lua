-- demo.lua
-- Comprehensive demo script for QwenUILib

-- Uses raw.githack.com proxy to bypass executor-level HTTP caching
local UILibrary = loadstring(game:HttpGet("https://raw.githack.com/aqquastudios28-lang/UiLib/main/build/bundle_plain.lua"))()


-- 2. Create the window
local Window = UILibrary.new(
    "QwenUILib Demo",      -- Game Name
    "Cerbis",              -- Username / UserID Display
    "Premium Developer"    -- Rank / Admin tag
)

-- Set Animation Speed (Percentage, default is 100)
Window:setAnimSpeed(120)

-- 3. Send a test notification
Window:Notification({
    Title = "Welcome!",
    Desc = "Modern & Rounded UI loaded successfully.",
    expire = 5 -- Auto-closes in 5 seconds
})

-- 4. Create first category (Main Features)
local MainCategory = Window:Category("Main", "rbxassetid://8349124615") -- Icon ID

-- Create buttons inside the category to act as tabs
local MainTab = MainCategory:Button("Autofarm", "rbxassetid://7072706663")
local ConfigTab = MainCategory:Button("Config", "rbxassetid://7072725342")

-- 5. Create sections in Autofarm Tab
local SectionLeft = MainTab:Section("Farming Controls", "Left")
local SectionRight = MainTab:Section("Utility Settings", "Right")

-- Add controls to Farming Controls (Left)
SectionLeft:Toggle({
    Title = "Auto Farm",
    Description = "Automatically harvest resources.",
    Default = false
}, function(state)
    print("Auto Farm set to:", state)
end)

SectionLeft:Slider({
    Title = "Speed Multiplier",
    Min = 1,
    Max = 100,
    Default = 50
}, function(value)
    print("Farming Speed set to:", value)
end)

SectionLeft:Dropdown({
    Title = "Target Mob",
    Options = {
        ["Goblin"] = true,
        ["Orc"] = false,
        ["Dragon"] = false
    },
    Multi = false -- Single selection dropdown
}, function(options)
    for mob, selected in pairs(options) do
        if selected then
            print("Selected Target Mob:", mob)
        end
    end
end)

-- Add controls to Utility Settings (Right)
SectionRight:Button({
    Title = "Instant Heal",
    Description = "Instantly restore health points.",
    ButtonName = "Execute Heal"
}, function()
    Window:Notification({
        Title = "Heal Triggered",
        Desc = "Restored 100% Health.",
        expire = 3
    })
end)

SectionRight:Keybind({
    Title = "Toggle UI Key",
    Default = Enum.KeyCode.RightControl
}, function()
    print("UI Toggle key pressed!")
end)

SectionRight:ColorPicker({
    Title = "Accent Color",
    Default = Color3.fromRGB(134, 142, 255)
}, function(color)
    print("Selected Accent Color:", color)
end)

-- 6. Create sections in Config Tab
local ConfigSection = ConfigTab:Section("General Config", "Left")

ConfigSection:Checkbox({
    Title = "Save Config on Exit",
    Default = true
}, function(state)
    print("Save on Exit set to:", state)
end)

ConfigSection:Textbox({
    Title = "Custom Prefix",
    Default = "!"
}, function(text)
    print("Prefix changed to:", text)
end)

-- 7. Add a Prompt verification
task.spawn(function()
    task.wait(2)
    local result = Window:Prompt({
        Title = "Execution Check",
        Desc = "Do you want to initialize the autofarm helper script?"
    })
    
    if result then
        Window:Notification({
            Title = "Success",
            Desc = "Autofarm initialized.",
            expire = 4
        })
    else
        Window:Notification({
            Title = "Cancelled",
            Desc = "Initialization cancelled by player.",
            expire = 4
        })
    end
end)
