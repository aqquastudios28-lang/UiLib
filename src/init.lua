-- src/init.lua
--[[
    QwenUILib - Premium Glass UI Library
    Modern, modular, and executor-safe
]]

local WindowModule = require(script.core.window)
local Notification = require(script.core.notification)
local Theme = require(script.core.theme)
print("[QwenUI] Core modules loaded!")

local Components = {
    Toggle = require(script.components.toggle),
    Button = require(script.components.button),
    Slider = require(script.components.slider),
    Dropdown = require(script.components.dropdown),
    MultiDropdown = require(script.components.multidropdown),
    ColorPicker = require(script.components.colorpicker),
    Keybind = require(script.components.keybind),
    Textbox = require(script.components.textbox),
    Section = require(script.components.section),
    Label = require(script.components.label),
    Paragraph = require(script.components.paragraph),
    Console = require(script.components.console)
}

local Library = {}

-- Expose global notification
function Library:Notify(config, parentGui)
    if not parentGui then
        local fallback = Library.ActiveScreenGui
        if not fallback then
            local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            fallback = playerGui and playerGui:FindFirstChildWhichIsA("ScreenGui")
        end
        parentGui = fallback
    end
    if parentGui then
        Notification.Notify(parentGui, config)
    end
end

function Library:CreateWindow(config)
    print("[QwenUI] CreateWindow called with config:", config and config.Name or "No Name")
    local Window = WindowModule.new(config)
    Library.ActiveScreenGui = Window.ScreenGui
    print("[QwenUI] Window created successfully!")
    
    -- Tab / Section / SubTab Methods
    local TabMethods = {}
    
    function TabMethods:CreateToggle(name, default, callback)
        return Components.Toggle(self, name, default, callback)
    end
    
    function TabMethods:CreateButton(name, callback)
        return Components.Button(self, name, callback)
    end
    
    function TabMethods:CreateSlider(name, min, max, default, callback)
        return Components.Slider(self, name, min, max, default, callback)
    end
    
    function TabMethods:CreateDropdown(name, options, default, callback)
        return Components.Dropdown(self, name, options, default, callback)
    end

    function TabMethods:CreateMultiDropdown(name, options, defaultSelected, callback)
        return Components.MultiDropdown(self, name, options, defaultSelected, callback)
    end
    
    function TabMethods:CreateColorPicker(name, defaultColor, callback)
        return Components.ColorPicker(self, name, defaultColor, callback)
    end
    
    function TabMethods:CreateKeybind(name, defaultKey, callback)
        return Components.Keybind(self, name, defaultKey, callback)
    end
    
    function TabMethods:CreateTextbox(name, placeholder, default, callback)
        return Components.Textbox(self, name, placeholder, default, callback)
    end

    function TabMethods:CreateLabel(text, alignment)
        return Components.Label(self, text, alignment)
    end

    function TabMethods:CreateParagraph(title, body)
        return Components.Paragraph(self, title, body)
    end

    function TabMethods:CreateConsole(name)
        return Components.Console(self, name)
    end
    
    function TabMethods:CreateSection(name)
        local section = Components.Section(self, name)
        -- Inject same methods into section
        setmetatable(section, {__index = TabMethods})
        return section
    end

    -- Override CreateTab to apply metatable and decorate CreateSubTab
    local originalCreateTab = Window.CreateTab
    function Window:CreateTab(name, icon, groupParent)
        local Tab = originalCreateTab(self, name, icon, groupParent)
        setmetatable(Tab, {__index = TabMethods})
        
        -- Override CreateSubTab to apply TabMethods to SubTabs
        local originalCreateSubTab = Tab.CreateSubTab
        function Tab:CreateSubTab(subName)
            local SubTab = originalCreateSubTab(self, subName)
            setmetatable(SubTab, {__index = TabMethods})
            return SubTab
        end
        
        return Tab
    end

    -- Apply initial custom theme parameters if provided
    if config.Theme then
        Theme:Update(config.Theme)
    end

    -- Automatically build the Theme Customizer Tab unless disabled
    if config.ThemeEditor ~= false then
        local SettingsGroup = Window:CreateTabGroup("Settings")
        local EditorTab = SettingsGroup:CreateTab("Theme Editor", "palette")
        
        local ColSec = EditorTab:CreateSection("Theme Colors")
        ColSec:CreateColorPicker("Accent Color", Theme.Accent, function(val)
            Theme:Update({
                Accent = val,
                AccentHover = val:lerp(Color3.new(1, 1, 1), 0.25),
                AccentDim = val:lerp(Color3.new(0, 0, 0), 0.25)
            })
        end)
        ColSec:CreateColorPicker("Background Color", Theme.Background, function(val)
            Theme:Update({ Background = val })
        end)
        ColSec:CreateColorPicker("Glass Color", Theme.Glass, function(val)
            Theme:Update({ Glass = val })
        end)
        ColSec:CreateColorPicker("Glass Border Color", Theme.GlassBorder, function(val)
            Theme:Update({ GlassBorder = val })
        end)
        ColSec:CreateColorPicker("Text Color", Theme.Text, function(val)
            Theme:Update({ Text = val })
        end)
        ColSec:CreateColorPicker("SubText Color", Theme.SubText, function(val)
            Theme:Update({ SubText = val })
        end)

        local TransSec = EditorTab:CreateSection("UI Transparency")
        TransSec:CreateSlider("Background Opacity", 0, 100, math.round((1 - Theme.BackgroundTransparency) * 100), function(val)
            Theme:Update({ BackgroundTransparency = 1 - (val / 100) })
        end)
        TransSec:CreateSlider("Glass Opacity", 0, 100, math.round((1 - Theme.GlassTransparency) * 100), function(val)
            Theme:Update({ GlassTransparency = 1 - (val / 100) })
        end)
        TransSec:CreateSlider("Shadow Opacity", 0, 100, math.round((1 - Theme.ShadowTransparency) * 100), function(val)
            Theme:Update({ ShadowTransparency = 1 - (val / 100) })
        end)

        local NeonSec = EditorTab:CreateSection("Liquid Neon")
        NeonSec:CreateColorPicker("Neon Glow 1", Theme.Blob1Color, function(val)
            Theme:Update({ Blob1Color = val })
        end)
        NeonSec:CreateColorPicker("Neon Glow 2", Theme.Blob2Color, function(val)
            Theme:Update({ Blob2Color = val })
        end)
        NeonSec:CreateSlider("Neon Transparency", 0, 100, math.round((1 - Theme.BlobTransparency) * 100), function(val)
            Theme:Update({ BlobTransparency = 1 - (val / 100) })
        end)
        NeonSec:CreateSlider("Neon Animation Speed", 0, 300, math.round(Theme.BlobSpeed * 100), function(val)
            Theme:Update({ BlobSpeed = val / 100 })
        end)

        local FontSec = EditorTab:CreateSection("Typography")
        local fonts = {"Gotham", "GothamMedium", "GothamBold", "SourceSans", "SourceSansBold", "Code"}
        local fontEnums = {
            ["Gotham"] = Enum.Font.Gotham,
            ["GothamMedium"] = Enum.Font.GothamMedium,
            ["GothamBold"] = Enum.Font.GothamBold,
            ["SourceSans"] = Enum.Font.SourceSans,
            ["SourceSansBold"] = Enum.Font.SourceSansBold,
            ["Code"] = Enum.Font.Code
        }
        
        -- Find current font name
        local currentFontName = "GothamMedium"
        for k, v in pairs(fontEnums) do
            if v == Theme.Font then
                currentFontName = k
                break
            end
        end
        
        FontSec:CreateDropdown("UI Font", fonts, currentFontName, function(val)
            local chosenFont = fontEnums[val]
            Theme:Update({
                Font = chosenFont,
                FontBold = (val:find("Bold") or val == "GothamBold") and chosenFont or Enum.Font.GothamBold
            })
        end)

        local ActionSec = EditorTab:CreateSection("Theme Actions")
        ActionSec:CreateButton("Copy Theme Table to Clipboard", function()
            local exportStr = "return {\n"
            for k, v in pairs(Theme.Values) do
                local valStr
                if typeof(v) == "Color3" then
                    valStr = string.format("Color3.fromRGB(%d, %d, %d)", math.round(v.R * 255), math.round(v.G * 255), math.round(v.B * 255))
                elseif typeof(v) == "EnumItem" then
                    valStr = "Enum.Font." .. tostring(v.Name or v)
                else
                    valStr = tostring(v)
                end
                exportStr = exportStr .. string.format("    %s = %s,\n", k, valStr)
            end
            exportStr = exportStr .. "}"
            
            if setclipboard then
                setclipboard(exportStr)
                Window:Notify({
                    Title = "Export Success",
                    Content = "Theme configuration copied to clipboard!",
                    Duration = 3,
                    Image = "check"
                })
            else
                print("[QwenUI Theme]\n" .. exportStr)
                Window:Notify({
                    Title = "Clipboard Error",
                    Content = "setclipboard not supported. Theme printed to executor console.",
                    Duration = 4,
                    Image = "error"
                })
            end
        end)
    end

    return Window
end

-- Version info
Library.Version = "2.0.0"
Library.Author = "QwenUI & Antigravity"

return Library