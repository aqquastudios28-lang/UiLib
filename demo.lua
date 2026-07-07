-- QwenUILib Demo
-- A minimal demo showcasing the bundled library

-- Load the bundled library
local QwenUI = loadstring(game:HttpGet("build/bundle.lua"))()

-- Initialize the library
QwenUI:Init()

-- Create a demo window
local Window = QwenUI:CreateWindow({
	Title = "QwenUILib Demo",
	Size = UDim2.new(0, 500, 0, 600),
	Theme = "Default"
})

-- Create a section
local Section = Window:AddSection("Getting Started")

-- Add a label
local Label = Section:AddLabel("Welcome to QwenUILib!")
Label:SetText("This is a premium Roblox UI library.")

-- Add a paragraph
local Paragraph = Section:AddParagraph("About", "QwenUILib provides a comprehensive set of UI components for Roblox games, including windows, buttons, toggles, sliders, and more.")

-- Add another section for inputs
local InputSection = Window:AddSection("Input Components")

-- Add a button
local Button = InputSection:AddButton("Click Me", function()
	QwenUI:Notify("Button clicked!", "info")
end)

-- Add a toggle
local Toggle = InputSection:AddToggle("Enable Feature", false, function(value)
	print("Toggle state:", value)
end)

-- Add a slider
local Slider = InputSection:AddSlider("Volume", 0, 100, 50, function(value)
	print("Slider value:", value)
end)

-- Add a dropdown
local Dropdown = InputSection:AddDropdown("Select Option", {"Option A", "Option B", "Option C"}, function(value)
	print("Selected:", value)
end)

-- Add a textbox
local TextBox = InputSection:AddTextBox("Enter Text", "Default text", function(value)
	print("Text:", value)
end)

-- Add a color picker
local ColorPicker = InputSection:AddColorPicker("Choose Color", Color3.new(1, 1, 1), function(color)
	print("Color:", color)
end)

-- Add a keybind
local Keybind = InputSection:AddKeybind("Hotkey", Enum.KeyCode.F, function(key)
	print("Key pressed:", key)
end)

-- Display section
local DisplaySection = Window:AddSection("Display Components")

-- Add a console
local Console = DisplaySection:AddConsole("Console Output", 5)
Console:Print("QwenUILib initialized!", "info")
Console:Print("This is a demo console.", "info")

-- Add a progress bar
local ProgressBar = DisplaySection:AddProgressBar("Loading...", 0, 100, 50)
ProgressBar:SetValue(75)

-- Add an image
local Image = DisplaySection:AddImage("Example Image", "rbxassetid://123456789", 200, 200)

-- Show a notification
QwenUI:Notify("QwenUILib Demo loaded successfully!", "success")

print("Demo loaded successfully!")