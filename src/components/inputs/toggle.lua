-- QwenUILib Toggle Component
-- Snappy toggle pill slider switches

local Toggle = {}
Toggle.__index = Toggle

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)

-- Create a toggle
function Toggle.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or "Toggle"
	local defaultState = config.Default or false
	local callback = config.Callback or function() end

	if not parent then
		error("Toggle requires a parent frame")
	end

	-- Main toggle container
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = ("Toggle_" .. tostring(text))
	toggleFrame.Size = UDim2.new(1, 0, 0, 36)
	toggleFrame.BackgroundTransparency = 1
	toggleFrame.ZIndex = 2

	-- Outer shell
	local outerShell = Instance.new("Frame")
	outerShell.Name = "OuterShell"
	outerShell.Size = UDim2.new(0, 44, 0, 24)
	outerShell.Position = UDim2.new(1, -52, 0.5, -12)
	outerShell.BackgroundColor3 = Theme.Colors.BackgroundTertiary
	outerShell.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
	outerShell.ZIndex = 2
	outerShell.ClipsDescendants = true

	local outerCorner = Utils.CreateCorner(12, outerShell)
	local outerStroke = Utils.CreateStroke(outerShell, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	outerShell.Parent = toggleFrame

	-- Slider pill
	local sliderPill = Instance.new("Frame")
	sliderPill.Name = "SliderPill"
	sliderPill.Size = UDim2.new(0, 18, 0, 18)
	sliderPill.Position = UDim2.new(0, 3, 0.5, -9)
	sliderPill.BackgroundColor3 = Theme.Colors.TextSecondary
	sliderPill.ZIndex = 3
	sliderPill.ClipsDescendants = true

	local sliderCorner = Utils.CreateCorner(9, sliderPill)

	sliderPill.Parent = outerShell

	-- Text label
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.new(1, -60, 1, 0)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = Theme.Colors.TextPrimary
	textLabel.TextSize = Theme.Font.Size.Body
	textLabel.Font = Theme.Font.Family
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.ZIndex = 2

	textLabel.Parent = toggleFrame

	-- Toggle state
	local toggleState = {
		Frame = toggleFrame,
		OuterShell = outerShell,
		SliderPill = sliderPill,
		TextLabel = textLabel,
		IsOn = defaultState,
		Callback = callback,
	}

	-- Update visual state
	local function updateVisual(state)
		if state then
			-- On state
			Utils.Tween(outerShell, {
				BackgroundColor3 = Theme.Colors.AccentPrimary,
				BackgroundTransparency = 0.3,
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			Utils.Tween(sliderPill, {
				Position = UDim2.new(1, -21, 0.5, -9),
				Size = UDim2.new(0, 18, 0, 18),
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		else
			-- Off state
			Utils.Tween(outerShell, {
				BackgroundColor3 = Theme.Colors.BackgroundTertiary,
				BackgroundTransparency = Theme.Transparency.BackgroundTertiary,
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			Utils.Tween(sliderPill, {
				Position = UDim2.new(0, 3, 0.5, -9),
				Size = UDim2.new(0, 18, 0, 18),
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end

	-- Click handler
	outerShell.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			-- Pressed effect
			Utils.Tween(sliderPill, {
				Size = UDim2.new(0, 14, 0, 14),
			}, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					-- Release
					Utils.Tween(sliderPill, {
						Size = UDim2.new(0, 18, 0, 18),
					}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

					-- Toggle state
					toggleState.IsOn = not toggleState.IsOn
					updateVisual(toggleState.IsOn)

					-- Callback
					task.spawn(callback, toggleState.IsOn)
				end
			end)
		end
	end)

	-- Hover effects
	outerShell.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if not toggleState.IsOn then
				Utils.Tween(outerShell, {
					BackgroundColor3 = Theme.Colors.BackgroundHover,
					BackgroundTransparency = Theme.Transparency.BackgroundHover,
				}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			end
		end
	end)

	outerShell.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if not toggleState.IsOn then
				Utils.Tween(outerShell, {
					BackgroundColor3 = Theme.Colors.BackgroundTertiary,
					BackgroundTransparency = Theme.Transparency.BackgroundTertiary,
				}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			end
		end
	end)

	-- Initialize state
	updateVisual(defaultState)

	-- Toggle methods
	function toggleState:SetState(state: boolean)
		toggleState.IsOn = state
		updateVisual(state)
	end

	function toggleState:GetState(): boolean
		return toggleState.IsOn
	end

	function toggleState:SetCallback(newCallback: (boolean) -> ())
		toggleState.Callback = newCallback
	end

	function toggleState:Destroy()
		Utils.Tween(toggleFrame, {
			Transparency = 1,
			Size = UDim2.new(0.5, 0, 0, 0),
			Position = UDim2.new(0.25, 0, 0.5, 0),
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.2, function()
			toggleFrame:Destroy()
		end)
	end

	-- Parent toggle
	toggleFrame.Parent = parent

	return toggleState
end

return Toggle