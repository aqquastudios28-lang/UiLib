-- QwenUILib Label Component
-- Aligned informational labels

local Label = {}
Label.__index = Label

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)

-- Create a label
function Label.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or "Label"
	local width = config.Width or UDim2.new(1, 0, 0, 20)
	local align = config.Align or Enum.TextXAlignment.Left
	local color = config.Color or Theme.Colors.TextPrimary
	local size = config.Size or Theme.Font.Size.Body
	local weight = config.Weight or Theme.Font.Weight.Regular

	if not parent then
		error("Label requires a parent frame")
	end

	-- Main label
	local labelFrame = Instance.new("TextLabel")
	labelFrame.Name = `Label_{text}`
	labelFrame.Size = width
	labelFrame.BackgroundTransparency = 1
	labelFrame.Text = text
	labelFrame.TextColor3 = color
	labelFrame.TextSize = size
	labelFrame.Font = Theme.Font.Family
	labelFrame.FontFace = Font.new(Theme.Font.Family, weight, size)
	labelFrame.TextXAlignment = align
	labelFrame.TextYAlignment = Enum.TextYAlignment.Top
	labelFrame.ZIndex = 2
	labelFrame.TextWrapped = true
	labelFrame.TextAutomaticSize = Enum.AutomaticSize.Y

	labelFrame.Parent = parent

	local labelState = {
		Frame = labelFrame,
	}

	-- Label methods
	function labelState:SetText(newText: string)
		labelState.Frame.Text = newText
	end

	function labelState:GetText(): string
		return labelState.Frame.Text
	end

	function labelState:SetColor(newColor: Color3)
		labelState.Frame.TextColor3 = newColor
	end

	function labelState:Destroy()
		labelFrame:Destroy()
	end

	return labelState
end

return Label