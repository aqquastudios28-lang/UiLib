-- QwenUILib Slider Component
-- Slider tracks with progress fill and numeric labels

local Slider = {}
Slider.__index = Slider

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)

-- Create a slider
function Slider.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or "Slider"
	local min = config.Min or 0
	local max = config.Max or 100
	local default = config.Default or 50
	local step = config.Step or 1
	local callback = config.Callback or function() end

	if not parent then
		error("Slider requires a parent frame")
	end

	-- Main slider container
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Name = `Slider_{text}`
	sliderFrame.Size = UDim2.new(1, 0, 0, 44)
	sliderFrame.BackgroundTransparency = 1
	sliderFrame.ZIndex = 2

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

	textLabel.Parent = sliderFrame

	-- Value label
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "Value"
	valueLabel.Size = UDim2.new(0, 60, 0, 20)
	valueLabel.Position = UDim2.new(1, -60, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = Theme.Colors.TextSecondary
	valueLabel.TextSize = Theme.Font.Size.Body
	valueLabel.Font = Theme.Font.Family
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextYAlignment = Enum.TextYAlignment.Center
	valueLabel.ZIndex = 2

	valueLabel.Parent = sliderFrame

	-- Track container
	local trackContainer = Instance.new("Frame")
	trackContainer.Name = "TrackContainer"
	trackContainer.Size = UDim2.new(1, 0, 0, 6)
	trackContainer.Position = UDim2.new(0, 0, 1, -16)
	trackContainer.BackgroundTransparency = 1
	trackContainer.ZIndex = 2

	trackContainer.Parent = sliderFrame

	-- Track background
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, 0, 1, 0)
	track.Position = UDim2.new(0, 0, 0, 0)
	track.BackgroundColor3 = Theme.Colors.BackgroundTertiary
	track.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
	track.ZIndex = 2

	local trackCorner = Utils.CreateCorner(3, track)
	track.Parent = trackContainer

	-- Progress fill
	local progress = Instance.new("Frame")
	progress.Name = "Progress"
	progress.Size = UDim2.new(0, 0, 1, 0)
	progress.Position = UDim2.new(0, 0, 0, 0)
	progress.BackgroundColor3 = Theme.Colors.AccentPrimary
	progress.BackgroundTransparency = 0.2
	progress.ZIndex = 2

	local progressCorner = Utils.CreateCorner(3, progress)
	progress.Parent = track

	-- Slider thumb
	local thumb = Instance.new("Frame")
	thumb.Name = "Thumb"
	thumb.Size = UDim2.new(0, 16, 0, 16)
	thumb.Position = UDim2.new(0, 0, 0.5, -8)
	thumb.BackgroundColor3 = Theme.Colors.AccentPrimary
	thumb.ZIndex = 3
	thumb.ClipsDescendants = true

	local thumbCorner = Utils.CreateCorner(8, thumb)
	local thumbStroke = Utils.CreateStroke(thumb, Theme.Colors.AccentPrimary, 2, 0)

	thumb.Parent = trackContainer

	-- Slider state
	local sliderState = {
		Frame = sliderFrame,
		Track = track,
		Progress = progress,
		Thumb = thumb,
		ValueLabel = valueLabel,
		Min = min,
		Max = max,
		CurrentValue = default,
		Step = step,
		Callback = callback,
		IsDragging = false,
	}

	-- Update slider position
	local function updateSlider(value)
		local clampedValue = math.clamp(value, min, max)
		local percent = (clampedValue - min) / (max - min)

		-- Update progress fill
		progress.Size = UDim2.new(percent, 0, 1, 0)

		-- Update thumb position
		thumb.Position = UDim2.new(percent, -8, 0.5, -8)

		-- Update value label
		local displayValue = math.round(clampedValue / step) * step
		valueLabel.Text = tostring(displayValue)

		sliderState.CurrentValue = displayValue
	end

	-- Click/drag handler
	local function handleInput(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliderState.IsDragging = true

			-- Scale up thumb
			Utils.Tween(thumb, {
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(thumb.Position.X.Scale, thumb.Position.X.Offset - 2, 0.5, -10),
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			local connection = RunService.Heartbeat:Connect(function()
				if not sliderState.IsDragging then
					connection:Disconnect()
					return
				end

				local mousePos = UserInputService:GetMouseLocation()
				local trackPos = track.AbsolutePosition.X
				local trackWidth = track.AbsoluteSize.X

				local relativeX = math.clamp(mousePos.X - trackPos, 0, trackWidth)
				local percent = relativeX / trackWidth
				local value = min + percent * (max - min)

				updateSlider(value)
				callback(math.round(value / step) * step)
			end)

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					sliderState.IsDragging = false
					connection:Disconnect()

					-- Scale down thumb
					Utils.Tween(thumb, {
						Size = UDim2.new(0, 16, 0, 16),
						Position = UDim2.new(thumb.Position.X.Scale, thumb.Position.X.Offset + 2, 0.5, -8),
					}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				end
			end)
		end
	end

	track.InputBegan:Connect(handleInput)
	thumb.InputBegan:Connect(handleInput)

	-- Hover effects
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			Utils.Tween(thumb, {
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(thumb.Position.X.Scale, thumb.Position.X.Offset - 1, 0.5, -9),
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)

	track.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and not sliderState.IsDragging then
			Utils.Tween(thumb, {
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(thumb.Position.X.Scale, thumb.Position.X.Offset + 1, 0.5, -8),
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)

	-- Initialize value
	updateSlider(default)

	-- Slider methods
	function sliderState:SetValue(value: number)
		updateSlider(value)
		callback(math.round(value / step) * step)
	end

	function sliderState:GetValue(): number
		return sliderState.CurrentValue
	end

	function sliderState:SetCallback(newCallback: (number) -> ())
		sliderState.Callback = newCallback
	end

	function sliderState:Destroy()
		Utils.Tween(sliderFrame, {
			Transparency = 1,
			Size = UDim2.new(0.5, 0, 0, 0),
			Position = UDim2.new(0.25, 0, 0.5, 0),
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.2, function()
			sliderFrame:Destroy()
		end)
	end

	-- Parent slider
	sliderFrame.Parent = parent

	return sliderState
end

return Slider