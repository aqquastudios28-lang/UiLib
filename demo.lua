-- QwenUILib Demo — full showcase of every component.
-- Loads the bundled library and builds a multi-tab window exercising all widgets.

local QwenUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/aqquastudios28-lang/UiLib/main/build/bundle.lua"))()

QwenUI:Init()

local Window = QwenUI:CreateWindow({
	Title = "QwenUILib — Showcase",
	Width = 560,
	Height = 640,
	Theme = "Default",
})

-- Tabs
local HomeTab = QwenUI:AddTab(Window, "Home")
local InputsTab = QwenUI:AddTab(Window, "Inputs")
local DisplayTab = QwenUI:AddTab(Window, "Display")
local LayoutTab = QwenUI:AddTab(Window, "Layout")
local NotifyTab = QwenUI:AddTab(Window, "Notify")

QwenUI:SwitchTab(Window, "Home")

-- ─────────────────────────────────────────────────────────────
-- HOME
-- ─────────────────────────────────────────────────────────────
QwenUI.Banner.Create({
	Parent = HomeTab.Content,
	Title = "QwenUILib",
	Subtitle = "Premium Roblox UI Library",
	Height = 110,
})

QwenUI.Label.Create({
	Parent = HomeTab.Content,
	Text = "Welcome to QwenUILib!",
})

QwenUI.Paragraph.Create({
	Parent = HomeTab.Content,
	Text = "A comprehensive component set for Roblox: windows with tabs, buttons, toggles, sliders, dropdowns, color pickers, keybinds, consoles, progress bars, notifications and more. Browse the tabs above to see every widget in action.",
})

QwenUI.Paragraph.Create({
	Parent = HomeTab.Content,
	Text = "Press RightShift to hide/show the window. Use the - button in the title bar to collapse it, and X to close it.",
})

QwenUI.Divider.Create({ Parent = HomeTab.Content, Text = "Get Started" })

QwenUI.Label.Create({
	Parent = HomeTab.Content,
	Text = "Version " .. tostring(QwenUI.Version) .. "  •  " .. tostring(QwenUI.Name),
})

-- ─────────────────────────────────────────────────────────────
-- INPUTS
-- ─────────────────────────────────────────────────────────────
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
		print("Toggle:", value)
	end,
})

QwenUI.Slider.Create({
	Parent = InputsTab.Content,
	Text = "Volume",
	Min = 0,
	Max = 100,
	Default = 50,
	Callback = function(value)
		print("Slider:", value)
	end,
})

QwenUI.Dropdown.Create({
	Parent = InputsTab.Content,
	Text = "Select Option",
	Options = { "Option A", "Option B", "Option C" },
	Default = "Option A",
	Callback = function(value)
		print("Dropdown:", value)
	end,
})

QwenUI.MultiDropdown.Create({
	Parent = InputsTab.Content,
	Text = "Select Multiple",
	Options = { "Red", "Green", "Blue", "Alpha" },
	Default = { "Red" },
	Callback = function(values)
		print("MultiDropdown:", values)
	end,
})

QwenUI.TextBox.Create({
	Parent = InputsTab.Content,
	Text = "Enter Text",
	Placeholder = "Type something...",
	Callback = function(value)
		print("TextBox:", value)
	end,
})

QwenUI.Keybind.Create({
	Parent = InputsTab.Content,
	Text = "Hotkey",
	Default = Enum.KeyCode.F,
	Callback = function(key)
		print("Keybind:", key)
	end,
})

QwenUI.ColorPicker.Create({
	Parent = InputsTab.Content,
	Text = "Choose Color",
	Default = Color3.fromRGB(124, 58, 237),
	Callback = function(color)
		print("Color:", color)
	end,
})

-- ─────────────────────────────────────────────────────────────
-- DISPLAY
-- ─────────────────────────────────────────────────────────────
QwenUI.Label.Create({ Parent = DisplayTab.Content, Text = "Display components" })

QwenUI.Paragraph.Create({
	Parent = DisplayTab.Content,
	Text = "Read-only widgets for surfacing information: labels, paragraphs, progress bars, a scrolling console, and images.",
})

local Loading = QwenUI.ProgressBar.Create({
	Parent = DisplayTab.Content,
	Text = "Loading...",
	Value = 25,
})
Loading:SetValue(75)

QwenUI.ProgressBar.Create({
	Parent = DisplayTab.Content,
	Text = "Storage",
	Value = 40,
})

local Console = QwenUI.Console.Create({
	Parent = DisplayTab.Content,
	Title = "Console Output",
	MaxLines = 50,
})
Console:Log("QwenUILib initialized!", "Success")
Console:Log("This is an info message.", "Info")
Console:Log("Careful — this is a warning.", "Warning")
Console:Log("Something went wrong.", "Error")
Console:Log("Verbose debug detail.", "Debug")

QwenUI.Image.Create({
	Parent = DisplayTab.Content,
	Image = "rbxassetid://4483345998",
	Caption = "Example Image",
})

-- ─────────────────────────────────────────────────────────────
-- LAYOUT
-- ─────────────────────────────────────────────────────────────
QwenUI.Label.Create({ Parent = LayoutTab.Content, Text = "Layout helpers" })

QwenUI.Divider.Create({ Parent = LayoutTab.Content })
QwenUI.Divider.Create({ Parent = LayoutTab.Content, Text = "Labeled Divider" })

-- Row: two half-width buttons side by side
local ButtonRow = QwenUI.Row.Create({ Parent = LayoutTab.Content, Gap = 8 })
QwenUI.Button.Create({
	Parent = ButtonRow.Frame,
	Text = "Accept",
	Width = UDim2.new(0.5, -4, 0, 44),
	Callback = function() QwenUI:Notify("Accepted", "Success") end,
})
QwenUI.Button.Create({
	Parent = ButtonRow.Frame,
	Text = "Decline",
	Width = UDim2.new(0.5, -4, 0, 44),
	Callback = function() QwenUI:Notify("Declined", "Error") end,
})

-- Collapsible section with nested widgets
local Section = QwenUI.Section.Create({
	Parent = LayoutTab.Content,
	Title = "Collapsible Section (click to toggle)",
})
QwenUI.Toggle.Create({
	Parent = Section.Content,
	Text = "Nested Toggle",
	Default = true,
	Callback = function(v) print("Nested toggle:", v) end,
})
QwenUI.Slider.Create({
	Parent = Section.Content,
	Text = "Nested Slider",
	Min = 0,
	Max = 10,
	Default = 5,
	Callback = function(v) print("Nested slider:", v) end,
})

QwenUI.Banner.Create({
	Parent = LayoutTab.Content,
	Title = "Banner Component",
	Subtitle = "Great for section headers",
	Height = 90,
})

-- ─────────────────────────────────────────────────────────────
-- NOTIFY
-- ─────────────────────────────────────────────────────────────
QwenUI.Paragraph.Create({
	Parent = NotifyTab.Content,
	Text = "Toast notifications slide in from the bottom, pause on hover, and auto-dismiss. Try each type:",
})

QwenUI.Button.Create({
	Parent = NotifyTab.Content,
	Text = "Info Notification",
	Callback = function() QwenUI:Notify("This is an info toast.", "Info") end,
})
QwenUI.Button.Create({
	Parent = NotifyTab.Content,
	Text = "Success Notification",
	Callback = function() QwenUI:Notify("Operation succeeded!", "Success") end,
})
QwenUI.Button.Create({
	Parent = NotifyTab.Content,
	Text = "Warning Notification",
	Callback = function() QwenUI:Notify("Heads up — check this.", "Warning") end,
})
QwenUI.Button.Create({
	Parent = NotifyTab.Content,
	Text = "Error Notification",
	Callback = function() QwenUI:Notify("Something failed.", "Error") end,
})

QwenUI:Notify("QwenUILib showcase loaded!", "Success")
print("QwenUILib showcase loaded successfully!")
