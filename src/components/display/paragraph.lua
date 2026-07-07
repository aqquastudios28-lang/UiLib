-- QwenUILib Paragraph Component
-- Text-wrapped body paragraphs

local Paragraph = {}
Paragraph.__index = Paragraph

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)

-- Create a paragraph
function Paragraph.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or "Paragraph text goes here..."
	local width = config.Width or UDim2.new(1, 0, 0, 0)
	local color = config.Color or Theme.Colors.TextSecondary
	local size = config.Size or Theme.Font.Size.Body
	local align = config.Align or Enum.TextXAlignment.Left

	if not parent then
		error("Paragraph requires a parent frame")
	end

	-- Main paragraph
	local paragraphFrame = Instance.new("TextLabel")
	paragraphFrame.Name = `Paragraph_{text:sub(1, 20)}`
	paragraphFrame.Size = width
	paragraphFrame.BackgroundTransparency = 1
	paragraphFrame.Text = text
	paragraphFrame.TextColor3 = color
	paragraphFrame.TextSize = size
	paragraphFrame.Font = Theme.Font.Family
	paragraphFrame.FontFace = Font.new(Theme.Font.Family, Theme.Font.Weight.Regular, size)
	paragraphFrame.TextXAlignment = align
	paragraphFrame.TextYAlignment = Enum.TextYAlignment.Top
	paragraphFrame.ZIndex = 2
	paragraphFrame.TextWrapped = true
	paragraphFrame.TextAutomaticSize = Enum.AutomaticSize.XY

	paragraphFrame.Parent = parent

	local paragraphState = {
		Frame = paragraphFrame,
	}

	-- Paragraph methods
	function paragraphState:SetText(newText: string)
		paragraphState.Frame.Text = newText
	end

	function paragraphState:GetText(): string
		return paragraphState.Frame.Text
	end

	function paragraphState:SetColor(newColor: Color3)
		paragraphState.Frame.TextColor3 = newColor
	end

	function paragraphState:Destroy()
		paragraphFrame:Destroy()
	end

	return paragraphState
end

return Paragraph