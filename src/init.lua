-- src/init.lua
--[[
    QwenUILib - Premium Glass UI Library
    Modern, modular, and executor-safe
]]

local WindowModule = require(script.core.window)
local Notification = require(script.core.notification)

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
        -- Attempt to find active UI screen or fallback to PlayerGui
        local fallback = game:GetService("CoreGui"):FindFirstChildWhichIsA("ScreenGui") or
                         game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChildWhichIsA("ScreenGui")
        parentGui = fallback
    end
    if parentGui then
        Notification.Notify(parentGui, config)
    end
end

function Library:CreateWindow(config)
    local Window = WindowModule.new(config)
    
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

    return Window
end

-- Version info
Library.Version = "2.0.0"
Library.Author = "QwenUI & Antigravity"

return Library