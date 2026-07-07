-- QwenUILib TextBox Component
-- Focus-glowing textbox inputs

local TextBox = {}
TextBox.__index = TextBox

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)

-- Create a textbox
function TextBox.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or ""
	local placeholder = config.Placeholder or "Enter text..."
	local width = config.Width or UDim2.new(1, 0, 0, 40)
	local callback = config.Callback or function() end
	local numbersOnly = config.NumbersOnly or false

	if not parent then
		error("TextBox requires a parent frame")
	end

	-- Main textbox container
	local textboxFrame = Instance.new("Frame")
	textboxFrame.Name = `TextBox_{text}`
	textboxFrame.Size = width
	textboxFrame.BackgroundColor3 = Theme.Colors.BackgroundTertiary
	textboxFrame.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
	textboxFrame.ZIndex = 2
	textboxFrame.ClipsDescendants = true

	local frameCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetOuter, textboxFrame)
	local frameStroke = Utils.CreateStroke(textboxFrame, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	-- Glow frame (for focus state)
	local glowFrame = Instance.new("Frame")
	glowFrame.Name = "Glow"
	glowFrame.Size = UDim2.new(1, -2, 1, -2)
	glowFrame.Position = UDim2.new(0, 1, 0, 1)
	glowFrame.BackgroundColor3 = Theme.Colors.AccentPrimary
	glowFrame.BackgroundTransparency = 1
	glowFrame.ZIndex = 1
	glowFrame.ClipsDescendants = true

	local glowCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetInner, glowFrame)
	glowFrame.Parent = textboxFrame

	-- Actual textbox
	local textbox = Instance.new("TextBox")
	textbox.Name = "Input"
	textbox.Size = UDim2.new(1, -16, 1, 0)
	textbox.Position = UDim2.new(0, 8, 0, 0)
	textbox.BackgroundTransparency = 1
	textbox.Text = text
	textbox.PlaceholderText = placeholder
	textbox.TextColor3 = Theme.Colors.TextPrimary
	textbox.PlaceholderColor3 = Theme.Colors.TextMuted
	textbox.TextSize = Theme.Font.Size.Body
	textbox.Font = Theme.Font.Family
	textbox.TextXAlignment = Enum.TextXAlignment.Left
	textbox.ZIndex = 3

	textbox.Parent = textboxFrame

	-- Cursor blink effect
	local cursorVisible = true
	local cursorConnection = RunService.Heartbeat:Connect(function()
		if textbox:IsFocused() then
			cursorVisible = not cursorVisible
			textbox.PlaceholderColor3 = cursorVisible and Theme.Colors.TextMuted or Theme.Colors.TextPrimary
		end
	end)

	-- TextBox state
	local textboxState = {
		Frame = textboxFrame,
		GlowFrame = glowFrame,
		TextBox = textbox,
		Callback = callback,
		NumbersOnly = numbersOnly,
	}

	-- Focus gained
	textbox.Focused:Connect(function()
		-- Glow effect
		Utils.Tween(glowFrame, {
			BackgroundTransparency = 0.8,
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		-- Border accent
		Utils.Tween(textboxFrame, {
			BackgroundColor3 = Theme.Colors.BackgroundHover,
			BackgroundTransparency = Theme.Transparency.BackgroundHover,
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end)

	-- Focus lost
	textbox.FocusLost:Connect(function(enterPressed)
		-- Remove glow
		Utils.Tween(glowFrame, {
			BackgroundTransparency = 1,
		}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		-- Reset border
		Utils.Tween(textboxFrame, {
			BackgroundColor3 = Theme.Colors.BackgroundTertiary,
			BackgroundTransparency = Theme.Transparency.BackgroundTertiary,
		}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		-- Trigger callback
		if enterPressed then
			task.spawn(callback, textbox.Text)
		end
	end)

	-- Text changed
	textbox:GetPropertyChangedSignal("Text"):Connect(function()
		if textboxState.NumbersOnly then
			-- Filter non-numeric characters
			local filtered = textbox.Text:gsub("[^0-9]", "")
			if filtered ~= textbox.Text then
				textbox.Text = filtered
			end
		end
	end)

	-- TextBox methods
	function textboxState:SetText(newText: string)
		textbox.Text = newText
	end

	function textboxState:GetText(): string
		return textbox.Text
	end

	function textboxState:SetPlaceholder(newPlaceholder: string)
		textbox.PlaceholderText = newPlaceholder
	end

	function textboxState:SetCallback(newCallback: (string) -> ())
		textboxState.Callback = newCallback
	end

	function textboxState:Clear()
		textbox.Text = ""
	end

	function textboxState:Focus()
		textbox:CaptureFocus()
	end

	function textboxState:Destroy()
		cursorConnection:Disconnect()

		Utils.Tween(textboxFrame, {
			Transparency = 1,
			Size = UDim2.new(0.5, 0, 0, 0),
			Position = UDim2.new(0.25, 0, 0.5, 0),
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.2, function()
			textboxFrame:Destroy()
		end)
	end

	-- Parent textbox
	textboxFrame.Parent = parent

	return textboxState
end

return TextBox