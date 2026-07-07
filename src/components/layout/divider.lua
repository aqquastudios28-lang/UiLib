-- QwenUILib Divider Component
-- Separators with optional centered text and side gradients

local Divider = {}
Divider.__index = Divider

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)

-- Create a divider
function Divider.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or ""
	local thickness = config.Thickness or 1
	local margin = config.Margin or Theme.Spacing.MD

	if not parent then
		error("Divider requires a parent frame")
	end

	-- Main divider container
	local dividerFrame = Instance.new("Frame")
	dividerFrame.Name = "Divider"
	dividerFrame.Size = UDim2.new(1, 0, 0, thickness)
	dividerFrame.BackgroundTransparency = 1
	dividerFrame.ZIndex = 2

	-- Left gradient line
	local leftLine = Instance.new("Frame")
	leftLine.Name = "LeftLine"
	leftLine.Size = UDim2.new(0.5, -margin / 2 - (text ~= "" and 50 or 0), 0, thickness)
	leftLine.Position = UDim2.new(0, 0, 0.5, -thickness / 2)
	leftLine.BackgroundColor3 = Theme.Colors.BorderPrimary
	leftLine.BackgroundTransparency = Theme.Transparency.Border
	leftLine.ZIndex = 2

	leftLine.Parent = dividerFrame

	-- Right gradient line
	local rightLine = Instance.new("Frame")
	rightLine.Name = "RightLine"
	rightLine.Size = UDim2.new(0.5, -margin / 2 - (text ~= "" and 50 or 0), 0, thickness)
	rightLine.Position = UDim2.new(0.5, margin / 2 + (text ~= "" and 50 or 0), 0.5, -thickness / 2)
	rightLine.BackgroundColor3 = Theme.Colors.BorderPrimary
	rightLine.BackgroundTransparency = Theme.Transparency.Border
	rightLine.ZIndex = 2

	rightLine.Parent = dividerFrame

	-- Optional center text
	if text ~= "" then
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Text"
		textLabel.Size = UDim2.new(0, 100, 0, 20)
		textLabel.Position = UDim2.new(0.5, -50, 0.5, -10)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = text
		textLabel.TextColor3 = Theme.Colors.TextMuted
		textLabel.TextSize = Theme.Font.Size.Small
		textLabel.Font = Theme.Font.Family
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.ZIndex = 2

		textLabel.Parent = dividerFrame
	end

	-- Parent divider
	dividerFrame.Parent = parent

	local dividerState = {
		Frame = dividerFrame,
		LeftLine = leftLine,
		RightLine = rightLine,
		TextLabel = text ~= "" and dividerFrame:FindFirstChild("Text") or nil,
	}

	-- Methods
	function dividerState:SetText(newText: string)
		if newText == "" then
			if dividerState.TextLabel then
				dividerState.TextLabel:Destroy()
				dividerState.TextLabel = nil
			end
			leftLine.Size = UDim2.new(1, 0, 0, thickness)
			rightLine.Visible = false
		else
			if not dividerState.TextLabel then
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "Text"
				textLabel.Size = UDim2.new(0, 100, 0, 20)
				textLabel.Position = UDim2.new(0.5, -50, 0.5, -10)
				textLabel.BackgroundTransparency = 1
				textLabel.Text = newText
				textLabel.TextColor3 = Theme.Colors.TextMuted
				textLabel.TextSize = Theme.Font.Size.Small
				textLabel.Font = Theme.Font.Family
				textLabel.TextXAlignment = Enum.TextXAlignment.Center
				textLabel.TextYAlignment = Enum.TextYAlignment.Center
				textLabel.ZIndex = 2

				textLabel.Parent = dividerFrame
				dividerState.TextLabel = textLabel

				leftLine.Size = UDim2.new(0.5, -50, 0, thickness)
				rightLine.Visible = true
			else
				dividerState.TextLabel.Text = newText
			end
		end
	end

	function dividerState:Destroy()
		dividerFrame:Destroy()
	end

	return dividerState
end

return Divider