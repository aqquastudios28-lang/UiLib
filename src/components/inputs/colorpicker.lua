-- QwenUILib ColorPicker Component
-- Collapsible SV area color pickers with Hue sliders

local ColorPicker = {}
ColorPicker.__index = ColorPicker

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)

-- Create a color picker
function ColorPicker.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or "ColorPicker"
	local default = config.Default or Color3.fromHex("#7c3aed")
	local callback = config.Callback or function() end

	if not parent then
		error("ColorPicker requires a parent frame")
	end

	-- Main color picker container
	local colorPickerFrame = Instance.new("Frame")
	colorPickerFrame.Name = `ColorPicker_{text}`
	colorPickerFrame.Size = UDim2.new(1, 0, 0, 200)
	colorPickerFrame.BackgroundTransparency = 1
	colorPickerFrame.ZIndex = 2

	-- Text label
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.new(0, 150, 0, 20)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = Theme.Colors.TextPrimary
	textLabel.TextSize = Theme.Font.Size.Body
	textLabel.Font = Theme.Font.Family
	textLabel.FontFace = Font.new(Theme.Font.Family, Theme.Font.Weight.Medium, Theme.Font.Size.Body)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.ZIndex = 2

	textLabel.Parent = colorPickerFrame

	-- Color preview button
	local previewButton = Instance.new("TextButton")
	previewButton.Name = "Preview"
	previewButton.Size = UDim2.new(0, 40, 0, 40)
	previewButton.Position = UDim2.new(1, -40, 0, 0)
	previewButton.BackgroundColor3 = default
	previewButton.ZIndex = 2
	previewButton.ClipsDescendants = true

	local previewCorner = Utils.CreateCorner(8, previewButton)
	local previewStroke = Utils.CreateStroke(previewButton, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	previewButton.Parent = colorPickerFrame

	-- Collapsible panel
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(1, 0, 0, 0)
	panel.Position = UDim2.new(0, 0, 0, 44)
	panel.BackgroundColor3 = Theme.Colors.BackgroundTertiary
	panel.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
	panel.ZIndex = 2
	panel.ClipsDescendants = true

	local panelCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetOuter, panel)
	local panelStroke = Utils.CreateStroke(panel, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	panel.Parent = colorPickerFrame

	-- SV (Saturation-Value) area
	local svArea = Instance.new("Frame")
	svArea.Name = "SVArea"
	svArea.Size = UDim2.new(1, -16, 0, 120)
	svArea.Position = UDim2.new(0, 8, 0, 8)
	svArea.BackgroundColor3 = Color3.fromHex("#ff0000")
	svArea.ZIndex = 3
	svArea.ClipsDescendants = true

	local svCorner = Utils.CreateCorner(Theme.CornerRadius.Small, svArea)

	-- White overlay for value
	local whiteOverlay = Instance.new("Frame")
	whiteOverlay.Name = "WhiteOverlay"
	whiteOverlay.Size = UDim2.new(1, 0, 1, 0)
	whiteOverlay.Position = UDim2.new(0, 0, 0, 0)
	whiteOverlay.BackgroundColor3 = Color3.fromHex("#ffffff")
	whiteOverlay.ZIndex = 4

	whiteOverlay.Parent = svArea

	-- Black overlay for saturation
	local blackOverlay = Instance.new("Frame")
	blackOverlay.Name = "BlackOverlay"
	blackOverlay.Size = UDim2.new(1, 0, 1, 0)
	blackOverlay.Position = UDim2.new(0, 0, 0, 0)
	blackOverlay.BackgroundTransparency = 0.5
	blackOverlay.ZIndex = 5

	blackOverlay.Parent = svArea

	svArea.Parent = panel

	-- SV selector
	local svSelector = Instance.new("Frame")
	svSelector.Name = "Selector"
	svSelector.Size = UDim2.new(0, 16, 0, 16)
	svSelector.Position = UDim2.new(0.5, -8, 0.5, -8)
	svSelector.BackgroundTransparency = 1
	svSelector.ZIndex = 6

	local selectorCorner = Utils.CreateCorner(8, svSelector)
	local selectorStroke = Utils.CreateStroke(svSelector, Color3.new(1, 1, 1), 2, 0)

	svSelector.Parent = svArea

	-- Hue slider
	local hueSlider = Instance.new("Frame")
	hueSlider.Name = "HueSlider"
	hueSlider.Size = UDim2.new(1, -16, 0, 20)
	hueSlider.Position = UDim2.new(0, 8, 0, 136)
	hueSlider.BackgroundColor3 = Color3.fromHex("#ff0000")
	hueSlider.ZIndex = 3
	hueSlider.ClipsDescendants = true

	local hueCorner = Utils.CreateCorner(4, hueSlider)

	-- Hue gradient (simplified with multiple frames)
	local hueGradient = Instance.new("Frame")
	hueGradient.Name = "Gradient"
	hueGradient.Size = UDim2.new(1, 0, 1, 0)
	hueGradient.Position = UDim2.new(0, 0, 0, 0)
	hueGradient.BackgroundTransparency = 1
	hueGradient.ZIndex = 4

	-- Create hue rainbow effect using ImageLabel
	local hueImage = Instance.new("ImageLabel")
	hueImage.Name = "HueImage"
	hueImage.Size = UDim2.new(1, 0, 1, 0)
	hueImage.Position = UDim2.new(0, 0, 0, 0)
	hueImage.BackgroundTransparency = 1
	hueImage.Image = "rbxassetid://6434342429" -- Rainbow gradient
	hueImage.ZIndex = 4

	hueImage.Parent = hueGradient
	hueGradient.Parent = hueSlider

	-- Hue thumb
	local hueThumb = Instance.new("Frame")
	hueThumb.Name = "Thumb"
	hueThumb.Size = UDim2.new(0, 4, 0, 24)
	hueThumb.Position = UDim2.new(0.5, -2, 0.5, -12)
	hueThumb.BackgroundColor3 = Color3.new(1, 1, 1)
	hueThumb.ZIndex = 5
	hueThumb.ClipsDescendants = true

	local hueThumbCorner = Utils.CreateCorner(2, hueThumb)
	local hueThumbStroke = Utils.CreateStroke(hueThumb, Color3.new(0, 0, 0), 1, 0)

	hueThumb.Parent = hueSlider

	hueSlider.Parent = panel

	-- ColorPicker state
	local colorPickerState = {
		Frame = colorPickerFrame,
		Panel = panel,
		PreviewButton = previewButton,
		SVArea = svArea,
		SVSelector = svSelector,
		HueSlider = hueSlider,
		HueThumb = hueThumb,
		CurrentColor = default,
		Hue = 0,
		Saturation = 1,
		Value = 1,
		IsOpen = false,
		Callback = callback,
	}

	-- Convert HSV to Color3
	local function hsvToColor(h, s, v)
		local c = v * s
		local x = c * (1 - math.abs((h / 60) % 2 - 1))
		local m = v - c

		local r, g, b = 0, 0, 0

		if h < 60 then
			r, g, b = c, x, 0
		elseif h < 120 then
			r, g, b = x, c, 0
		elseif h < 180 then
			r, g, b = 0, c, x
		elseif h < 240 then
			r, g, b = 0, x, c
		elseif h < 300 then
			r, g, b = x, 0, c
		else
			r, g, b = c, 0, x
		end

		return Color3.new(r + m, g + m, b + m)
	end

	-- Update color
	local function updateColor()
		local color = hsvToColor(colorPickerState.Hue, colorPickerState.Saturation, colorPickerState.Value)
		colorPickerState.CurrentColor = color

		-- Update preview
		previewButton.BackgroundColor3 = color

		-- Update SV area background
		local baseColor = hsvToColor(colorPickerState.Hue, 1, 1)
		svArea.BackgroundColor3 = baseColor

		-- Update SV selector position
		svSelector.Position = UDim2.new(colorPickerState.Saturation, -8, 1 - colorPickerState.Value, -8)

		-- Callback
		task.spawn(callback, color)
	end

	-- Toggle panel
	previewButton.MouseButton1Click:Connect(function()
		colorPickerState.IsOpen = not colorPickerState.IsOpen

		if colorPickerState.IsOpen then
			-- Open panel
			panel.Visible = true
			panel.Size = UDim2.new(1, 0, 0, 0)

			Utils.Tween(panel, {
				Size = UDim2.new(1, 0, 0, 160),
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		else
			-- Close panel
			Utils.Tween(panel, {
				Size = UDim2.new(1, 0, 0, 0),
			}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

			task.delay(0.2, function()
				panel.Visible = false
			end)
		end
	end)

	-- SV area drag
	local function svDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local connection = RunService.Heartbeat:Connect(function()
				local mousePos = UserInputService:GetMouseLocation()
				local areaPos = svArea.AbsolutePosition
				local areaSize = svArea.AbsoluteSize

				local relativeX = math.clamp(mousePos.X - areaPos.X, 0, areaSize.X)
				local relativeY = math.clamp(mousePos.Y - areaPos.Y, 0, areaSize.Y)

				colorPickerState.Saturation = relativeX / areaSize.X
				colorPickerState.Value = 1 - (relativeY / areaSize.Y)

				updateColor()
			end)

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					connection:Disconnect()
				end
			end)
		end
	end

	svArea.InputBegan:Connect(svDrag)
	svSelector.InputBegan:Connect(svDrag)

	-- Hue slider drag
	local function hueDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local connection = RunService.Heartbeat:Connect(function()
				local mousePos = UserInputService:GetMouseLocation()
				local sliderPos = hueSlider.AbsolutePosition.X
				local sliderWidth = hueSlider.AbsoluteSize.X

				local relativeX = math.clamp(mousePos.X - sliderPos, 0, sliderWidth)
				local percent = relativeX / sliderWidth

				colorPickerState.Hue = percent * 360
				hueThumb.Position = UDim2.new(percent, -2, 0.5, -12)

				updateColor()
			end)

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					connection:Disconnect()
				end
			end)
		end
	end

	hueSlider.InputBegan:Connect(hueDrag)
	hueThumb.InputBegan:Connect(hueDrag)

	-- Initialize color
	updateColor()

	-- ColorPicker methods
	function colorPickerState:SetColor(color: Color3)
		colorPickerState.CurrentColor = color
		previewButton.BackgroundColor3 = color

		-- Convert to HSV (simplified)
		local h, s, v = Color3.toHSV(color)
		colorPickerState.Hue = h * 360
		colorPickerState.Saturation = s
		colorPickerState.Value = v

		updateColor()
	end

	function colorPickerState:GetColor(): Color3
		return colorPickerState.CurrentColor
	end

	function colorPickerState:SetCallback(newCallback: (Color3) -> ())
		colorPickerState.Callback = newCallback
	end

	function colorPickerState:Destroy()
		Utils.Tween(colorPickerFrame, {
			Transparency = 1,
			Size = UDim2.new(0.5, 0, 0, 0),
			Position = UDim2.new(0.25, 0, 0.5, 0),
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.2, function()
			colorPickerFrame:Destroy()
		end)
	end

	-- Parent color picker
	colorPickerFrame.Parent = parent

	return colorPickerState
end

return ColorPicker