-- QwenUILib ProgressBar Component
-- XP-style read-only loading/progress metrics

local ProgressBar = {}
ProgressBar.__index = ProgressBar

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)

-- Create a progress bar
function ProgressBar.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or "Progress"
	local value = config.Value or 0
	local width = config.Width or UDim2.new(1, 0, 0, 24)

	if not parent then
		error("ProgressBar requires a parent frame")
	end

	-- Main progress bar container
	local progressFrame = Instance.new("Frame")
	progressFrame.Name = ("ProgressBar_" .. tostring(text))
	progressFrame.Size = width
	progressFrame.BackgroundTransparency = 1
	progressFrame.ZIndex = 2

	-- Text label (optional)
	local textLabel = nil
	if text ~= "" then
		textLabel = Instance.new("TextLabel")
		textLabel.Name = "Text"
		textLabel.Size = UDim2.new(1, 0, 0, 20)
		textLabel.Position = UDim2.new(0, 0, 1, -20)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = text
		textLabel.TextColor3 = Theme.Colors.TextSecondary
		textLabel.TextSize = Theme.Font.Size.Small
		textLabel.Font = Theme.Font.Family
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Top
		textLabel.ZIndex = 2

		textLabel.Parent = progressFrame
	end

	-- Track background
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, 0, 0, 12)
	track.Position = UDim2.new(0, 0, text ~= "" and 0 or 0.5, text ~= "" and 8 or -6)
	track.BackgroundColor3 = Theme.Colors.BackgroundTertiary
	track.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
	track.ZIndex = 2
	track.ClipsDescendants = true

	local trackCorner = Utils.CreateCorner(6, track)
	track.Parent = progressFrame

	-- Progress fill
	local progressFill = Instance.new("Frame")
	progressFill.Name = "Fill"
	progressFill.Size = UDim2.new(0, 0, 1, 0)
	progressFill.Position = UDim2.new(0, 0, 0, 0)
	progressFill.BackgroundColor3 = Theme.Colors.AccentPrimary
	progressFill.BackgroundTransparency = 0.2
	progressFill.ZIndex = 2

	local fillCorner = Utils.CreateCorner(6, progressFill)
	progressFill.Parent = track

	-- Glossy shine effect
	local shine = Instance.new("Frame")
	shine.Name = "Shine"
	shine.Size = UDim2.new(1, 0, 0, 4)
	shine.Position = UDim2.new(0, 0, 0, 0)
	shine.BackgroundColor3 = Color3.new(1, 1, 1)
	shine.BackgroundTransparency = 0.3
	shine.ZIndex = 3
	shine.ClipsDescendants = true

	local shineCorner = Utils.CreateCorner(6, shine)
	shine.Parent = progressFill

	-- Value label
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "Value"
	valueLabel.Size = UDim2.new(0, 50, 0, 20)
	valueLabel.Position = UDim2.new(1, 8, text ~= "" and 0 or 0.5, text ~= "" and 8 or -10)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = (tostring(math.round(value)) .. "%")
	valueLabel.TextColor3 = Theme.Colors.TextSecondary
	valueLabel.TextSize = Theme.Font.Size.Small
	valueLabel.Font = Theme.Font.Family
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextYAlignment = Enum.TextYAlignment.Top
	valueLabel.ZIndex = 2

	valueLabel.Parent = progressFrame

	-- ProgressBar state
	local progressState = {
		Frame = progressFrame,
		Track = track,
		ProgressFill = progressFill,
		ValueLabel = valueLabel,
		TextLabel = textLabel,
		CurrentValue = value,
	}

	-- Update progress
	local function updateProgress(newValue)
		local clampedValue = math.clamp(newValue, 0, 100)
		local percent = clampedValue / 100

		-- Animate fill
		Utils.Tween(progressFill, {
			Size = UDim2.new(percent, 0, 1, 0),
		}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		-- Update value label
		valueLabel.Text = (tostring(math.round(clampedValue)) .. "%")

		progressState.CurrentValue = clampedValue
	end

	-- Initialize
	updateProgress(value)

	-- ProgressBar methods
	function progressState:SetValue(newValue: number)
		updateProgress(newValue)
	end

	function progressState:GetValue(): number
		return progressState.CurrentValue
	end

	function progressState:SetText(newText: string)
		if progressState.TextLabel then
			progressState.TextLabel.Text = newText
		end
	end

	function progressState:Destroy()
		Utils.Tween(progressFrame, {
			Transparency = 1,
			Size = UDim2.new(0.5, 0, 0, 0),
			Position = UDim2.new(0.25, 0, 0.5, 0),
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.2, function()
			progressFrame:Destroy()
		end)
	end

	-- Parent progress bar
	progressFrame.Parent = parent

	return progressState
end

return ProgressBar