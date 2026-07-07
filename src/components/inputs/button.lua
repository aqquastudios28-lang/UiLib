-- QwenUILib Button Component
-- Tactile buttons with nested right icon pill and ripple physics

local Button = {}
Button.__index = Button

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)
local Icons = require(script.Parent.Parent.Icons)

-- Create a button
function Button.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or "Button"
	local icon = config.Icon or ""
	local width = config.Width or UDim2.new(1, 0, 0, 44)
	local callback = config.Callback or function() end
	local disabled = config.Disabled or false

	if not parent then
		error("Button requires a parent frame")
	end

	-- Outer shell (concentric bezel)
	local outerShell = Instance.new("Frame")
	outerShell.Name = ("Button_" .. tostring(text))
	outerShell.Size = width
	outerShell.BackgroundColor3 = Theme.Colors.BackgroundTertiary
	outerShell.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
	outerShell.ZIndex = 2
	outerShell.ClipsDescendants = true

	local outerCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetOuter, outerShell)
	local outerStroke = Utils.CreateStroke(outerShell, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	-- Inner core
	local innerCore = Instance.new("Frame")
	innerCore.Name = "InnerCore"
	innerCore.Size = UDim2.new(1, -6, 1, -6)
	innerCore.Position = UDim2.new(0, 3, 0, 3)
	innerCore.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	innerCore.BackgroundTransparency = Theme.Transparency.BackgroundSecondary
	innerCore.ZIndex = 2
	innerCore.ClipsDescendants = true

	local innerCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetInner, innerCore)
	innerCore.Parent = outerShell

	-- Text label
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.new(1, -48, 1, 0)
	textLabel.Position = UDim2.new(0, 16, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = disabled and Theme.Colors.TextMuted or Theme.Colors.TextPrimary
	textLabel.TextSize = Theme.Font.Size.Body
	textLabel.Font = Theme.Font.Family
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.ZIndex = 3

	textLabel.Parent = innerCore

	-- Icon pill (if icon provided)
	local iconPill = nil
	if icon ~= "" then
		iconPill = Icons.CreatePill(
			icon,
			innerCore,
			26,
			Theme.Colors.AccentPrimary,
			0.85,
			"Filled"
		)
		iconPill.Position = UDim2.new(1, -38, 0.5, -13)
		iconPill.ZIndex = 3
	end

	-- Ripple effect container
	local rippleContainer = Instance.new("Frame")
	rippleContainer.Name = "Ripples"
	rippleContainer.Size = UDim2.new(1, 0, 1, 0)
	rippleContainer.Position = UDim2.new(0, 0, 0, 0)
	rippleContainer.BackgroundTransparency = 1
	rippleContainer.ZIndex = 2
	rippleContainer.ClipsDescendants = true

	rippleContainer.Parent = innerCore

	-- Button state
	local buttonState = {
		Frame = outerShell,
		InnerCore = innerCore,
		TextLabel = textLabel,
		IconPill = iconPill,
		RippleContainer = rippleContainer,
		IsDisabled = disabled,
		Callback = callback,
	}

	-- Ripple effect
	local function createRipple(x, y)
		if disabled then return end

		local ripple = Instance.new("Frame")
		ripple.Name = "Ripple"
		ripple.Size = UDim2.new(0, 0, 0, 0)
		ripple.Position = UDim2.new(0, x, 0, y)
		ripple.BackgroundColor3 = Color3.new(1, 1, 1)
		ripple.BackgroundTransparency = 0.3
		ripple.ZIndex = 2

		local rippleCorner = Utils.CreateCorner(50, ripple)
		ripple.Parent = rippleContainer

		-- Expand ripple
		Utils.Tween(ripple, {
			Size = UDim2.new(0, 200, 0, 200),
			Position = UDim2.new(0, x - 100, 0, y - 100),
		}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		-- Fade out ripple
		Utils.Tween(ripple, {
			BackgroundTransparency = 0.8,
		}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		task.delay(0.5, function()
			if ripple.Parent then
				ripple:Destroy()
			end
		end)
	end

	-- Click handler
	outerShell.InputBegan:Connect(function(input)
		if disabled then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			-- Get click position relative to button
			local mousePos = input.Position
			local buttonPos = outerShell.AbsolutePosition
			local relativeX = mousePos.X - buttonPos.X
			local relativeY = mousePos.Y - buttonPos.Y

			-- Create ripple
			createRipple(relativeX, relativeY)

			-- Pressed scale effect
			Utils.Tween(innerCore, {
				Size = UDim2.new(1, -10, 1, -10),
				Position = UDim2.new(0, 5, 0, 5),
			}, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			-- Accent glow
			Utils.Tween(outerShell, {
				BackgroundColor3 = Theme.Colors.AccentPrimary,
				BackgroundTransparency = 0.3,
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					-- Release scale effect
					Utils.Tween(innerCore, {
						Size = UDim2.new(1, -6, 1, -6),
						Position = UDim2.new(0, 3, 0, 3),
					}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

					-- Remove accent glow
					Utils.Tween(outerShell, {
						BackgroundColor3 = Theme.Colors.BackgroundTertiary,
						BackgroundTransparency = Theme.Transparency.BackgroundTertiary,
					}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

					-- Trigger callback
					task.spawn(callback)
				end
			end)
		end
	end)

	-- Hover effects
	outerShell.InputBegan:Connect(function(input)
		if disabled or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

		Utils.Tween(outerShell, {
			BackgroundColor3 = Theme.Colors.BackgroundHover,
			BackgroundTransparency = Theme.Transparency.BackgroundHover,
		}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end)

	outerShell.InputEnded:Connect(function(input)
		if disabled or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

		Utils.Tween(outerShell, {
			BackgroundColor3 = Theme.Colors.BackgroundTertiary,
			BackgroundTransparency = Theme.Transparency.BackgroundTertiary,
		}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end)

	-- Button methods
	function buttonState:SetText(newText: string)
		buttonState.TextLabel.Text = newText
	end

	function buttonState:SetDisabled(isDisabled: boolean)
		buttonState.IsDisabled = isDisabled
		buttonState.TextLabel.TextColor3 = isDisabled and Theme.Colors.TextMuted or Theme.Colors.TextPrimary
	end

	function buttonState:SetCallback(newCallback: () -> ())
		buttonState.Callback = newCallback
	end

	function buttonState:Destroy()
		Utils.Tween(outerShell, {
			Transparency = 1,
			Size = UDim2.new(0.5, 0, 0, 0),
			Position = UDim2.new(0.25, 0, 0.5, 0),
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.2, function()
			outerShell:Destroy()
		end)
	end

	-- Parent button
	outerShell.Parent = parent

	return buttonState
end

return Button