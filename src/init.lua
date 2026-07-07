-- QwenUILib Main Entrypoint
-- Premium Roblox UI Library - Awwwards-tier Design System

local QwenUI = {}
QwenUI.__index = QwenUI

-- Services
local Players = game:GetService("Players")

-- Core modules
local Theme = require(script.Theme)
local Utils = require(script.Utils)
local Icons = require(script.Icons)
local Window = require(script.Window)
local Notification = require(script.Notification)

-- Component modules
local Section = require(script.components.layout.Section)
local Row = require(script.components.layout.Row)
local Divider = require(script.components.layout.Divider)
local Banner = require(script.components.layout.Banner)

local Button = require(script.components.inputs.Button)
local Toggle = require(script.components.inputs.Toggle)
local Slider = require(script.components.inputs.Slider)
local TextBox = require(script.components.inputs.TextBox)
local Dropdown = require(script.components.inputs.Dropdown)
local MultiDropdown = require(script.components.inputs.MultiDropdown)
local ColorPicker = require(script.components.inputs.ColorPicker)
local Keybind = require(script.components.inputs.Keybind)

local Console = require(script.components.display.Console)
local ProgressBar = require(script.components.display.ProgressBar)
local Label = require(script.components.display.Label)
local Paragraph = require(script.components.display.Paragraph)
local Image = require(script.components.display.Image)

-- Library info
QwenUI.Version = "1.0.0"
QwenUI.Name = "QwenUILib"

-- Create a new window
function QwenUI:CreateWindow(config: table)
	config = config or {}
	return Window.Create(config)
end

-- Create a notification
function QwenUI:Notify(message: string, type: string?, parent: Instance?)
	return Notification.Create(message, type, parent)
end

-- Theme management
function QwenUI:GetTheme()
	return Theme
end

function QwenUI:ApplyPreset(presetName: string)
	Theme:ApplyPreset(presetName)
	Icons:LoadPreset(presetName)
end

-- Icons management
function QwenUI:GetIcons()
	return Icons
end

function QwenUI:RegisterIcon(name: string, assetId: string, weight: string?)
	return Icons:Register(name, assetId, weight)
end

-- Utilities access
function QwenUI:GetUtils()
	return Utils
end

-- Component factory functions
QwenUI.Section = Section
QwenUI.Row = Row
QwenUI.Divider = Divider
QwenUI.Banner = Banner

QwenUI.Button = Button
QwenUI.Toggle = Toggle
QwenUI.Slider = Slider
QwenUI.TextBox = TextBox
QwenUI.Dropdown = Dropdown
QwenUI.MultiDropdown = MultiDropdown
QwenUI.ColorPicker = ColorPicker
QwenUI.Keybind = Keybind

QwenUI.Console = Console
QwenUI.ProgressBar = ProgressBar
QwenUI.Label = Label
QwenUI.Paragraph = Paragraph
QwenUI.Image = Image

-- Preset configurations
QwenUI.Presets = {
	Default = {
		Theme = Theme,
		Icons = "Phosphor",
	},
	Light = {
		Theme = Theme,
		Icons = "Phosphor",
		Colors = Theme.Light,
	},
}

-- Apply a preset
function QwenUI:UsePreset(presetName: string)
	if self.Presets[presetName] then
		local preset = self.Presets[presetName]
		self:ApplyPreset(preset.Icons)
		-- Additional preset logic can be added here
	end
end

-- Cleanup all windows
function QwenUI:DestroyAll()
	Window.DestroyAll()
end

-- Initialize library
function QwenUI:Init()
	-- Set up default icon preset
	Icons:LoadPreset("Phosphor")

	-- Print initialization message
	print(`{self.Name} v{self.Version} initialized successfully!`)
	print("Premium Roblox UI Library - Awwwards-tier Design System")
	print("Components: Window, Notifications, Section, Row, Divider, Banner")
	print("Inputs: Button, Toggle, Slider, TextBox, Dropdown, MultiDropdown, ColorPicker, Keybind")
	print("Display: Console, ProgressBar, Label, Paragraph, Image")

	return self
end

-- Export module
return QwenUI