-- QwenUILib Console Component
-- Log streams with clear, copy, filtering, and colored level outputs

local Console = {}
Console.__index = Console

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)
local Icons = require(script.Parent.Parent.Icons)

-- Create a console
function Console.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local title = config.Title or "Console"
	local maxLines = config.MaxLines or 100

	if not parent then
		error("Console requires a parent frame")
	end

	-- Main console container
	local consoleFrame = Instance.new("Frame")
	consoleFrame.Name = ("Console_" .. tostring(title))
	consoleFrame.Size = UDim2.new(1, 0, 0, 300)
	consoleFrame.BackgroundTransparency = 1
	consoleFrame.ZIndex = 2

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 32)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.BackgroundColor3 = Theme.Colors.BackgroundTertiary
	header.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
	header.ZIndex = 2

	local headerCorner = Utils.CreateCorner(Theme.CornerRadius.Button, header)
	local headerStroke = Utils.CreateStroke(header, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	header.Parent = consoleFrame

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.Position = UDim2.new(0, 12, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.Colors.TextPrimary
	titleLabel.TextSize = Theme.Font.Size.Header
	titleLabel.Font = Theme.Font.Family
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.ZIndex = 2

	titleLabel.Parent = header

	-- Clear button
	local clearButton = Instance.new("TextButton")
	clearButton.Name = "ClearButton"
	clearButton.Size = UDim2.new(0, 24, 0, 24)
	clearButton.Position = UDim2.new(1, -60, 0.5, -12)
	clearButton.BackgroundTransparency = 1
	clearButton.Text = ""
	clearButton.ZIndex = 2

	local clearIcon = Icons.Create(
		"trash",
		clearButton,
		UDim2.new(0, 16, 0, 16),
		UDim2.new(0.5, -8, 0.5, -8),
		Theme.Colors.TextMuted,
		0.6
	)

	clearButton.Parent = header

	-- Copy button
	local copyButton = Instance.new("TextButton")
	copyButton.Name = "CopyButton"
	copyButton.Size = UDim2.new(0, 24, 0, 24)
	copyButton.Position = UDim2.new(1, -32, 0.5, -12)
	copyButton.BackgroundTransparency = 1
	copyButton.Text = ""
	copyButton.ZIndex = 2

	local copyIcon = Icons.Create(
		"copy",
		copyButton,
		UDim2.new(0, 16, 0, 16),
		UDim2.new(0.5, -8, 0.5, -8),
		Theme.Colors.TextMuted,
		0.6
	)

	copyButton.Parent = header

	-- Log container
	local logContainer = Instance.new("ScrollingFrame")
	logContainer.Name = "LogContainer"
	logContainer.Size = UDim2.new(1, 0, 1, -32)
	logContainer.Position = UDim2.new(0, 0, 0, 32)
	logContainer.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	logContainer.BackgroundTransparency = Theme.Transparency.BackgroundSecondary
	logContainer.ZIndex = 2
	logContainer.ClipsDescendants = true
	logContainer.ScrollBarThickness = 4
	logContainer.ScrollBarImageColor3 = Theme.Colors.AccentPrimary
	logContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	Utils.AutoCanvasY(logContainer)

	local logCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetInner, logContainer)
	logContainer.Parent = consoleFrame

	-- Log layout
	local logLayout = Instance.new("UIListLayout")
	logLayout.FillDirection = Enum.FillDirection.Vertical
	logLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	logLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	logLayout.Padding = UDim.new(0, 4)
	logLayout.SortOrder = Enum.SortOrder.LayoutOrder
	logLayout.Parent = logContainer

	-- Console state
	local consoleState = {
		Frame = consoleFrame,
		LogContainer = logContainer,
		LogLayout = logLayout,
		MaxLines = maxLines,
		LineCount = 0,
	}

	-- Log levels
	local LogLevels = {
		Info = { Color = Theme.Colors.Info, Prefix = "[INFO]" },
		Success = { Color = Theme.Colors.Success, Prefix = "[SUCCESS]" },
		Warning = { Color = Theme.Colors.Warning, Prefix = "[WARNING]" },
		Error = { Color = Theme.Colors.Error, Prefix = "[ERROR]" },
		Debug = { Color = Theme.Colors.TextMuted, Prefix = "[DEBUG]" },
	}

	-- Add log entry
	function consoleState:Log(message: string, level: string?)
		level = level or "Info"
		local logData = LogLevels[level] or LogLevels.Info

		-- Create log entry
		local entry = Instance.new("TextLabel")
		entry.Name = ("Log_" .. tostring(self.LineCount))
		entry.Size = UDim2.new(1, -16, 0, 20)
		entry.Position = UDim2.new(0, 8, 0, 0)
		entry.BackgroundTransparency = 1
		entry.Text = (tostring(logData.Prefix) .. " " .. tostring(message))
		entry.TextColor3 = logData.Color
		entry.TextSize = Theme.Font.Size.Small
		entry.Font = Theme.Font.Family
		entry.TextXAlignment = Enum.TextXAlignment.Left
		entry.TextYAlignment = Enum.TextYAlignment.Center
		entry.ZIndex = 3
		pcall(function()
			entry.TextTruncate = Enum.TextTruncate.AtEnd
		end)

		entry.Parent = logContainer
		self.LineCount = self.LineCount + (1)

		-- Remove old lines if exceeding max
		if self.LineCount > maxLines then
			for i, child in ipairs(logContainer:GetChildren()) do
				if child.Name:match("^Log_") and child ~= entry then
					child:Destroy()
					self.LineCount = self.LineCount - (1)
					break
				end
			end
		end

		-- Scroll to bottom (deferred so the layout has measured the new entry;
		-- AbsoluteContentSize works on old executor clients where
		-- AbsoluteCanvasSize does not)
		task.delay(0.03, function()
			local target = logLayout.AbsoluteContentSize.Y - logContainer.AbsoluteSize.Y
			logContainer.CanvasPosition = Vector2.new(0, math.max(0, target))
		end)
	end

	-- Clear console
	function consoleState:Clear()
		for _, child in ipairs(logContainer:GetChildren()) do
			if child.Name:match("^Log_") then
				child:Destroy()
			end
		end
		self.LineCount = 0
	end

	-- Copy all logs
	function consoleState:Copy()
		local logs = {}
		for _, child in ipairs(logContainer:GetChildren()) do
			if child.Name:match("^Log_") then
				table.insert(logs, child.Text)
			end
		end

		local text = table.concat(logs, "\n")

		if setclipboard then
			setclipboard(text)
		end
	end

	-- Filter logs
	function consoleState:Filter(level: string)
		for _, child in ipairs(logContainer:GetChildren()) do
			if child.Name:match("^Log_") then
				local isMatch = child.Text:find(level:upper())
				child.Visible = isMatch ~= nil
			end
		end
	end

	-- Button handlers
	clearButton.MouseButton1Click:Connect(function()
		consoleState:Clear()
	end)

	copyButton.MouseButton1Click:Connect(function()
		consoleState:Copy()
	end)

	-- Hover effects
	clearButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			Utils.Tween(clearButton, {
				BackgroundTransparency = 0.8,
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)

	clearButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			Utils.Tween(clearButton, {
				BackgroundTransparency = 1,
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)

	copyButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			Utils.Tween(copyButton, {
				BackgroundTransparency = 0.8,
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)

	copyButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			Utils.Tween(copyButton, {
				BackgroundTransparency = 1,
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)

	-- Console methods
	function consoleState:Destroy()
		Utils.Tween(consoleFrame, {
			Transparency = 1,
			Size = UDim2.new(0.5, 0, 0, 0),
			Position = UDim2.new(0.25, 0, 0.5, 0),
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.2, function()
			consoleFrame:Destroy()
		end)
	end

	-- Parent console
	consoleFrame.Parent = parent

	return consoleState
end

return Console