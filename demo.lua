-- QwenUILib Demo
-- A minimal demo showcasing the bundled library

-- Load the bundled library
local QwenUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/aqquastudios28-lang/UiLib/main/build/bundle.lua"))()

-- Initialize the library
QwenUI:Init()

-- Create a demo window
local Window = QwenUI:CreateWindow({
	Title = "QwenUILib Demo",
	Size = UDim2.new(0, 500, 0, 600),
	Theme = "Default"
})

-- Create tabs
local HomeTab = QwenUI:AddTab(Window, "Home")
local InputsTab = QwenUI:AddTab(Window, "Inputs")
local DisplayTab = QwenUI:AddTab(Window, "Display")

-- Switch to the first tab
QwenUI:SwitchTab(Window, "Home")

-- Populate Home tab
local HomeSection = HomeTab.Content:FindFirstChild("ContentContainer") and HomeTab.Content or Instance.new("Frame")
HomeSection.Name = "HomeSection"
HomeSection.Size = UDim2.new(1, 0, 0, 0)
HomeSection.BackgroundTransparency = 1

local HomeLabel = HomeSection:AddLabel("Welcome to QwenUILib!")
HomeLabel:SetText("This is a premium Roblox UI library with tabs.")

local HomeParagraph = HomeSection:AddParagraph("About", "QwenUILib provides a comprehensive set of UI components for Roblox games, including windows, buttons, toggles, sliders, and more.")

HomeSection.Parent = HomeTab.Content

-- Populate Inputs tab
local InputSection = InputsTab.Content:FindFirstChild("ContentContainer") and InputsTab.Content or Instance.new("Frame")
InputSection.Name = "InputSection"
InputSection.Size = UDim2.new(1, 0, 0, 0)
InputSection.BackgroundTransparency = 1

local Button = InputSection:AddButton("Click Me", function()
	QwenUI:Notify("Button clicked!", "info")
end)

local Toggle = InputSection:AddToggle("Enable Feature", false, function(value)
	print("Toggle state:", value)
end)

local Slider = InputSection:AddSlider("Volume", 0, 100, 50, function(value)
	print("Slider value:", value)
end)

local Dropdown = InputSection:AddDropdown("Select Option", {"Option A", "Option B", "Option C"}, function(value)
	print("Selected:", value)
end)

local TextBox = InputSection:AddTextBox("Enter Text", "Default text", function(value)
	print("Text:", value)
end)

local ColorPicker = InputSection:AddColorPicker("Choose Color", Color3.new(1, 1, 1), function(color)
	print("Color:", color)
end)

local Keybind = InputSection:AddKeybind("Hotkey", Enum.KeyCode.F, function(key)
	print("Key pressed:", key)
end)

InputSection.Parent = InputsTab.Content

-- Populate Display tab
local DisplaySection = DisplayTab.Content:FindFirstChild("ContentContainer") and DisplayTab.Content or Instance.new("Frame")
DisplaySection.Name = "DisplaySection"
DisplaySection.Size = UDim2.new(1, 0, 0, 0)
DisplaySection.BackgroundTransparency = 1

local Console = DisplaySection:AddConsole("Console Output", 5)
Console:Print("QwenUILib initialized!", "info")
Console:Print("This is a demo console.", "info")

local ProgressBar = DisplaySection:AddProgressBar("Loading...", 0, 100, 50)
ProgressBar:SetValue(75)

local Image = DisplaySection:AddImage("Example Image", "rbxassetid://123456789", 200, 200)

DisplaySection.Parent = DisplayTab.Content

-- Show a notification
QwenUI:Notify("QwenUILib Demo loaded successfully!", "success")

print("Demo loaded successfully!")
