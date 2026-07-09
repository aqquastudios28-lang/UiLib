-- demo.lua
-- Comprehensive demo script for QwenUILib with extensive execution tracing

print("[DEBUG] 1. Initializing demo script...")

local url = "https://raw.githack.com/aqquastudios28-lang/UiLib/main/build/bundle_plain.lua"
print("[DEBUG] 2. Requesting raw UI Library content from URL:", url)

local success, content = pcall(function()
    return game:HttpGet(url)
end)

if not success then
    error("[DEBUG] HttpGet failed to fetch raw file: " .. tostring(content))
end

print("[DEBUG] 3. Successfully fetched content. Length:", #content)

local func, compile_err = loadstring(content)
if not func then
    error("[DEBUG] Loadstring compilation failed: " .. tostring(compile_err))
end

print("[DEBUG] 4. Loadstring compilation successful. Executing library...")

local exec_success, UILibrary = pcall(func)
if not exec_success then
    error("[DEBUG] Library execution/instantiation failed: " .. tostring(UILibrary))
end

print("[DEBUG] 5. Library loaded successfully! Type of UILibrary:", type(UILibrary))

print("[DEBUG] 6. Creating UI Window...")
local Window = UILibrary.new(
    "QwenUILib Demo",      -- Game Name
    "Cerbis",              -- Username / UserID Display
    "Premium Developer"    -- Rank / Admin tag
)
print("[DEBUG] Window created successfully!")

print("[DEBUG] 7. Adjusting animation speed...")
Window:setAnimSpeed(120)

print("[DEBUG] 8. Sending welcome Notification...")
Window:Notification({
    Title = "Welcome!",
    Desc = "Modern & Rounded UI loaded successfully.",
    expire = 5
})

print("[DEBUG] 9. Creating category 'Main'...")
local MainCategory = Window:Category("Main", "rbxassetid://8349124615")
print("[DEBUG] Category 'Main' created successfully.")

print("[DEBUG] 10. Creating 'Autofarm' tab button...")
local MainTab = MainCategory:Button("Autofarm", "rbxassetid://7072706663")
print("[DEBUG] Tab 'Autofarm' created successfully.")

print("[DEBUG] 11. Creating 'Config' tab button...")
local ConfigTab = MainCategory:Button("Config", "rbxassetid://7072725342")
print("[DEBUG] Tab 'Config' created successfully.")

print("[DEBUG] 12. Creating left section 'Farming Controls' inside Autofarm tab...")
local SectionLeft = MainTab:Section("Farming Controls", "Left")
print("[DEBUG] Section 'Farming Controls' created.")

print("[DEBUG] 13. Creating right section 'Utility Settings' inside Autofarm tab...")
local SectionRight = MainTab:Section("Utility Settings", "Right")
print("[DEBUG] Section 'Utility Settings' created.")

print("[DEBUG] 14. Adding Auto Farm toggle to left section...")
SectionLeft:Toggle({
    Title = "Auto Farm",
    Description = "Automatically harvest resources.",
    Default = false
}, function(state)
    print("[EVENT] Auto Farm state changed to:", state)
end)
print("[DEBUG] Toggle 'Auto Farm' added.")

print("[DEBUG] 15. Adding Speed Multiplier slider to left section...")
SectionLeft:Slider({
    Title = "Speed Multiplier",
    Min = 1,
    Max = 100,
    Default = 50
}, function(value)
    print("[EVENT] Speed Multiplier value changed to:", value)
end)
print("[DEBUG] Slider 'Speed Multiplier' added.")

print("[DEBUG] 16. Adding Target Mob dropdown to left section...")
SectionLeft:Dropdown({
    Title = "Target Mob",
    Options = {
        ["Goblin"] = true,
        ["Orc"] = false,
        ["Dragon"] = false
    },
    Multi = false
}, function(options)
    for mob, selected in pairs(options) do
        if selected then
            print("[EVENT] Selected Target Mob:", mob)
        end
    end
end)
print("[DEBUG] Dropdown 'Target Mob' added.")

print("[DEBUG] 17. Adding Instant Heal button to right section...")
SectionRight:Button({
    Title = "Instant Heal",
    Description = "Instantly restore health points.",
    ButtonName = "Execute Heal"
}, function()
    print("[EVENT] Button 'Instant Heal' clicked!")
    Window:Notification({
        Title = "Heal Triggered",
        Desc = "Restored 100% Health.",
        expire = 3
    })
end)
print("[DEBUG] Button 'Instant Heal' added.")

print("[DEBUG] 18. Adding Toggle UI Key keybind to right section...")
SectionRight:Keybind({
    Title = "Toggle UI Key",
    Default = Enum.KeyCode.RightControl
}, function()
    print("[EVENT] Keybind pressed!")
end)
print("[DEBUG] Keybind 'Toggle UI Key' added.")

print("[DEBUG] 19. Adding Accent Color colorpicker to right section...")
SectionRight:ColorPicker({
    Title = "Accent Color",
    Default = Color3.fromRGB(134, 142, 255)
}, function(color)
    print("[EVENT] Color selected:", color)
end)
print("[DEBUG] ColorPicker 'Accent Color' added.")

print("[DEBUG] 20. Creating left section 'General Config' inside Config tab...")
local ConfigSection = ConfigTab:Section("General Config", "Left")
print("[DEBUG] Section 'General Config' created.")

print("[DEBUG] 21. Adding Save Config on Exit checkbox to Config tab...")
ConfigSection:Checkbox({
    Title = "Save Config on Exit",
    Default = true
}, function(state)
    print("[EVENT] Save Config checkbox changed to:", state)
end)
print("[DEBUG] Checkbox 'Save Config on Exit' added.")

print("[DEBUG] 22. Adding Custom Prefix textbox to Config tab...")
ConfigSection:Textbox({
    Title = "Custom Prefix",
    Default = "!"
}, function(text)
    print("[EVENT] Prefix textbox changed to:", text)
end)
print("[DEBUG] Textbox 'Custom Prefix' added.")

print("[DEBUG] 23. Starting prompt verification task (deferred)...")
task.spawn(function()
    print("[DEBUG] Prompt task started. Waiting 2 seconds before prompting...")
    task.wait(2)
    print("[DEBUG] Prompting user with Choice dialog...")
    local result = Window:Prompt({
        Title = "Execution Check",
        Desc = "Do you want to initialize the autofarm helper script?"
    })
    
    print("[DEBUG] Prompt returned result:", result)
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

print("[DEBUG] 24. Demo script successfully loaded! Checking screen GUI...")
