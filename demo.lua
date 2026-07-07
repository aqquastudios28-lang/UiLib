-- QwenUILib Demo
-- Showcases the bundled library using its real component API.

-- Load the bundled library
local QwenUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/aqquastudios28-lang/UiLib/main/build/bundle.lua"))()

-- Initialize the library
QwenUI:Init()

-- Create a demo window (mounts itself inside a protected ScreenGui)
local Window = QwenUI:CreateWindow({
	Title = "QwenUILib Demo",
	Width = 500,
	Height = 600,
	Theme = "Default",
})

-- Create tabs
local HomeTab = QwenUI:AddTab(Window, "Home")
local InputsTab = QwenUI:AddTab(Window, "Inputs")
local DisplayTab = QwenUI:AddTab(Window, "Display")

-- Show the Home tab
QwenUI:SwitchTab(Window, "Home")

-- Populate Home tab
QwenUI.Label.Create({
	Parent = HomeTab.Content,
	Text = "Welcome to QwenUILib!",
})

QwenUI.Paragraph.Create({
	Parent = HomeTab.Content,
	Text = "QwenUILib provides a comprehensive set of UI components for Roblox: windows, buttons, toggles, sliders, dropdowns, and more.",
})

-- Populate Inputs tab
QwenUI.Button.Create({
	Parent = InputsTab.Content,
	Text = "Click Me",
	Callback = function()
		QwenUI:Notify("Button clicked!", "Info")
	end,
})

QwenUI.Toggle.Create({
	Parent = InputsTab.Content,
	Text = "Enable Feature",
	Default = false,
	Callback = function(value)
		print("Toggle state:", value)
	end,
})

QwenUI.Slider.Create({
	Parent = InputsTab.Content,
	Text = "Volume",
	Min = 0,
	Max = 100,
	Default = 50,
	Callback = function(value)
		print("Slider value:", value)
	end,
})

QwenUI.Dropdown.Create({
	Parent = InputsTab.Content,
	Text = "Select Option",
	Options = { "Option A", "Option B", "Option C" },
	Default = "Option A",
	Callback = function(value)
		print("Selected:", value)
	end,
})

QwenUI.TextBox.Create({
	Parent = InputsTab.Content,
	Text = "Enter Text",
	Placeholder = "Default text",
	Callback = function(value)
		print("Text:", value)
	end,
})

QwenUI.ColorPicker.Create({
	Parent = InputsTab.Content,
	Text = "Choose Color",
	Default = Color3.new(1, 1, 1),
	Callback = function(color)
		print("Color:", color)
	end,
})

QwenUI.Keybind.Create({
	Parent = InputsTab.Content,
	Text = "Hotkey",
	Default = Enum.KeyCode.F,
	Callback = function(key)
		print("Key pressed:", key)
	end,
})

-- Populate Display tab
local Console = QwenUI.Console.Create({
	Parent = DisplayTab.Content,
	Title = "Console Output",
	MaxLines = 50,
})
Console:Log("QwenUILib initialized!", "Info")
Console:Log("This is a demo console.", "Info")

local ProgressBar = QwenUI.ProgressBar.Create({
	Parent = DisplayTab.Content,
	Text = "Loading...",
	Value = 50,
})
ProgressBar:SetValue(75)

QwenUI.Image.Create({
	Parent = DisplayTab.Content,
	Image = "rbxassetid://123456789",
	Caption = "Example Image",
})

-- Show a notification
QwenUI:Notify("QwenUILib Demo loaded successfully!", "Success")

print("Demo loaded successfully!")
