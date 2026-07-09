-- demo.lua
-- Comprehensive, feature-complete demo script for QwenUILib

print("[DEBUG] 1. Initializing demo script...")

-- Load the library from the latest sandbox-fixed, redesigned UI commit to bypass all CDN caching
local url = "https://raw.githubusercontent.com/aqquastudios28-lang/UiLib/a21dd3497c643bf03da8e980801b0d80d2a23c8c/build/bundle_plain.lua"
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

-- 1. Create the Window
print("[DEBUG] 6. Creating UI Window...")
local Window = UILibrary.new(
    "QwenUILib Redesign",  -- Game/Hub Name
    "Cerbis",              -- Username Display
    "Premium Developer"    -- Rank Display
)
print("[DEBUG] Window created successfully!")

-- Adjust animation speed (default 100)
Window:setAnimSpeed(125)

-- 2. Send Initial Welcome Notification
print("[DEBUG] 7. Sending welcome notification...")
Window:Notification({
    Title = "Library Ready!",
    Desc = " Redesigned glassmorphic UI loaded successfully.",
    expire = 6
})

-- 3. Create Main Categories (Main Column 1 tabs in the left-most sidebar)
print("[DEBUG] 8. Creating main categories...")
local MainCategory = Window:Category("Combat", "rbxassetid://8349124615")
local SettingsCategory = Window:Category("Settings", "rbxassetid://7072725342")

-- 4. Create Category Buttons (Subtabs in Column 2 under Main Category)
print("[DEBUG] 9. Creating subtabs under Combat category...")
local CombatTab = MainCategory:Button("Combat Cheats", "rbxassetid://7072706663")
local MovementTab = MainCategory:Button("Movement Cheats", "rbxassetid://8343977772")

print("[DEBUG] 10. Creating subtabs under Settings category...")
local VisualsTab = SettingsCategory:Button("UI Theme", "rbxassetid://7072725342")
local SystemTab = SettingsCategory:Button("Config", "rbxassetid://7072725342")

-- 5. Build COMBAT TAB Sections and Controls
print("[DEBUG] 11. Building Combat Tab sections...")
local AimbotSection = CombatTab:Section("Aimbot Settings", "Left")
local TriggerSection = CombatTab:Section("Triggerbot Settings", "Right")

-- Aimbot Section Controls
AimbotSection:Toggle({
    Title = "Enable Aimbot",
    Description = "Automatically locks onto target players.",
    Default = false
}, function(state)
    print("[EVENT] Aimbot Enabled:", state)
end)

AimbotSection:Slider({
    Title = "Aimbot FOV",
    Min = 10,
    Max = 360,
    Default = 90
}, function(value)
    print("[EVENT] Aimbot FOV set to:", value)
end)

AimbotSection:Dropdown({
    Title = "Aimbot Target Part",
    Options = {
        ["Head"] = true,
        ["HumanoidRootPart"] = false,
        ["UpperTorso"] = false
    },
    Multi = false
}, function(options)
    for part, selected in pairs(options) do
        if selected then
            print("[EVENT] Aimbot Target Part set to:", part)
        end
    end
end)

AimbotSection:Checkbox({
    Title = "Show FOV Circle",
    Default = true
}, function(state)
    print("[EVENT] Show FOV Circle:", state)
end)

-- Triggerbot Section Controls
TriggerSection:Toggle({
    Title = "Enable Triggerbot",
    Description = "Automatically shoots when a target is in crosshair.",
    Default = false
}, function(state)
    print("[EVENT] Triggerbot Enabled:", state)
end)

TriggerSection:Slider({
    Title = "Trigger Delay (ms)",
    Min = 0,
    Max = 500,
    Default = 50
}, function(value)
    print("[EVENT] Trigger Delay set to:", value)
end)

TriggerSection:Dropdown({
    Title = "Weapon Group Filter",
    Options = {
        ["Rifles"] = true,
        ["Pistols"] = true,
        ["Snipers"] = false,
        ["Shotguns"] = false
    },
    Multi = true
}, function(options)
    print("[EVENT] Selected Weapon Groups:")
    for group, enabled in pairs(options) do
        print("  - " .. group .. ":", enabled)
    end
end)

TriggerSection:Keybind({
    Title = "Triggerbot Keybind",
    Default = Enum.KeyCode.V
}, function()
    print("[EVENT] Triggerbot Keybind pressed!")
end)

-- 6. Build MOVEMENT TAB Sections and Controls
print("[DEBUG] 12. Building Movement Tab sections...")
local PhysicsSection = MovementTab:Section("Physics Modifiers", "Left")
local TeleportSection = MovementTab:Section("Utility Teleports", "Right")

PhysicsSection:Slider({
    Title = "WalkSpeed Hack",
    Min = 16,
    Max = 150,
    Default = 16
}, function(speed)
    print("[EVENT] WalkSpeed changed to:", speed)
end)

PhysicsSection:Slider({
    Title = "JumpPower Hack",
    Min = 50,
    Max = 300,
    Default = 50
}, function(power)
    print("[EVENT] JumpPower changed to:", power)
end)

PhysicsSection:Toggle({
    Title = "Infinite Jump",
    Description = "Allows infinite jumping in mid-air.",
    Default = false
}, function(state)
    print("[EVENT] Infinite Jump:", state)
end)

PhysicsSection:Checkbox({
    Title = "Noclip Active",
    Default = false
}, function(state)
    print("[EVENT] Noclip state set to:", state)
end)

TeleportSection:Button({
    Title = "Teleport to Spawn",
    Description = "Teleport instantly to the world spawn location.",
    ButtonName = "Teleport Now"
}, function()
    print("[EVENT] Teleporting player to spawn...")
    Window:Notification({
        Title = "Teleported",
        Desc = "Successfully moved to World Spawn point.",
        expire = 3
    })
end)

TeleportSection:Textbox({
    Title = "Teleport Player Name",
    Default = "Username"
}, function(text)
    print("[EVENT] Target Teleport player username changed to:", text)
end)

TeleportSection:Button({
    Title = "Teleport to Target Player",
    Description = "Move directly to the targeted player.",
    ButtonName = "Go to Player"
}, function()
    print("[EVENT] Attempting teleport to target player...")
end)

-- 7. Build THEME TAB Sections and Controls
print("[DEBUG] 13. Building UI Theme Tab sections...")
local AccentSection = VisualsTab:Section("Theme Accent", "Left")

AccentSection:ColorPicker({
    Title = "Primary Accent Color",
    Default = Color3.fromRGB(134, 142, 255)
}, function(color)
    print("[EVENT] Primary Accent color changed to:", color)
end)

AccentSection:Button({
    Title = "Test Success Prompt",
    Description = "Opens verification choice prompt dialog.",
    ButtonName = "Trigger Prompt"
}, function()
    print("[DEBUG] Verification prompt opened manually.")
    local result = Window:Prompt({
        Title = "Theme Test",
        Desc = "Do you want to confirm these changes?"
    })
    
    print("[DEBUG] Theme verification prompt returned:", result)
    if result then
        Window:Notification({
            Title = "Theme Confirmed",
            Desc = "UI Accent configuration successfully verified.",
            expire = 4
        })
    else
        Window:Notification({
            Title = "Cancelled",
            Desc = "UI Accent verification cancelled.",
            expire = 4
        })
    end
end)

-- 8. Build SYSTEM CONFIG TAB Sections and Controls
print("[DEBUG] 14. Building Config Tab sections...")
local ConfigSection = SystemTab:Section("Configuration Profiles", "Left")

ConfigSection:Textbox({
    Title = "Configuration Name",
    Default = "default_profile"
}, function(text)
    print("[EVENT] Profile name set to:", text)
end)

ConfigSection:Button({
    Title = "Save Config",
    Description = "Write active options to config profile.",
    ButtonName = "Save Now"
}, function()
    Window:Notification({
        Title = "Profile Saved",
        Desc = "Active configurations written successfully.",
        expire = 3
    })
end)

ConfigSection:Button({
    Title = "Load Config",
    Description = "Load saved configurations from profile.",
    ButtonName = "Load Now"
}, function()
    Window:Notification({
        Title = "Profile Loaded",
        Desc = "UI configuration loaded successfully.",
        expire = 3
    })
end)

-- 9. Trigger Initial Delayed Prompt
print("[DEBUG] 15. Scheduling initial delayed Choice Prompt...")
task.spawn(function()
    task.wait(3.5)
    print("[DEBUG] Initial Choice Prompt triggered.")
    local result = Window:Prompt({
        Title = "Auto-Farm Choice",
        Desc = "Would you like to initialize the Auto-Farm helper service?"
    })
    
    print("[DEBUG] Initial Choice Prompt returned:", result)
    if result then
        Window:Notification({
            Title = "Success",
            Desc = "Auto-Farm helper initialized.",
            expire = 4
        })
    else
        Window:Notification({
            Title = "Cancelled",
            Desc = "Auto-Farm initialization aborted.",
            expire = 4
        })
    end
end)

print("[DEBUG] 16. Demo script loaded completely and running!")
