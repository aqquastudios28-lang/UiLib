-- QwenUILib MultiDropdown Component
-- Multi-select option lists with search filtering

local MultiDropdown = {}
MultiDropdown.__index = MultiDropdown

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)
local Icons = require(script.Parent.Parent.Icons)

-- Create a multidropdown
function MultiDropdown.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or "MultiDropdown"
	local options = config.Options or {}
	local default = config.Default or {}
	local callback = config.Callback or function() end

	if not parent then
		error("MultiDropdown requires a parent frame")
	end

	-- Main multidropdown container
	local multidropdownFrame = Instance.new("Frame")
	multidropdownFrame.Name = ("MultiDropdown_" .. tostring(text))
	multidropdownFrame.Size = UDim2.new(1, 0, 0, 40)
	multidropdownFrame.BackgroundTransparency = 1
	multidropdownFrame.ZIndex = 2

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
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.ZIndex = 2

	textLabel.Parent = multidropdownFrame

	-- Dropdown button
	local dropdownButton = Instance.new("TextButton")
	dropdownButton.Name = "Button"
	dropdownButton.Size = UDim2.new(1, 0, 0, 32)
	dropdownButton.Position = UDim2.new(0, 0, 1, -32)
	dropdownButton.BackgroundColor3 = Theme.Colors.BackgroundTertiary
	dropdownButton.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
	dropdownButton.ZIndex = 2
	dropdownButton.ClipsDescendants = true

	local buttonCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetOuter, dropdownButton)
	local buttonStroke = Utils.CreateStroke(dropdownButton, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	dropdownButton.Parent = multidropdownFrame

	-- Selected count text
	local selectedText = Instance.new("TextLabel")
	selectedText.Name = "Selected"
	selectedText.Size = UDim2.new(1, -40, 1, 0)
	selectedText.Position = UDim2.new(0, 12, 0, 0)
	selectedText.BackgroundTransparency = 1
	selectedText.Text = #default > 0 and (tostring(#default) .. " selected") or "Select..."
	selectedText.TextColor3 = #default > 0 and Theme.Colors.TextPrimary or Theme.Colors.TextMuted
	selectedText.TextSize = Theme.Font.Size.Body
	selectedText.Font = Theme.Font.Family
	selectedText.TextXAlignment = Enum.TextXAlignment.Left
	selectedText.TextYAlignment = Enum.TextYAlignment.Center
	selectedText.ZIndex = 3

	selectedText.Parent = dropdownButton

	-- Dropdown arrow icon
	local arrowIcon = Icons.Create(
		"caret-down",
		dropdownButton,
		UDim2.new(0, 20, 0, 20),
		UDim2.new(1, -28, 0.5, -10),
		Theme.Colors.TextSecondary,
		0.8
	)

	-- Dropdown list (hidden by default)
	local dropdownList = Instance.new("ScrollingFrame")
	dropdownList.Name = "List"
	dropdownList.Size = UDim2.new(1, 0, 0, 0)
	dropdownList.Position = UDim2.new(0, 0, 1, 0)
	dropdownList.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	dropdownList.BackgroundTransparency = Theme.Transparency.BackgroundSecondary
	dropdownList.ZIndex = 10
	dropdownList.Visible = false
	dropdownList.ClipsDescendants = true
	dropdownList.ScrollBarThickness = 4
	dropdownList.ScrollBarImageColor3 = Theme.Colors.AccentPrimary
	dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
	Utils.AutoCanvasY(dropdownList)

	local listCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetOuter, dropdownList)
	local listStroke = Utils.CreateStroke(dropdownList, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	dropdownList.Parent = multidropdownFrame

	-- List layout
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.Padding = UDim.new(0, 4)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = dropdownList

	-- MultiDropdown state
	local multidropdownState = {
		Frame = multidropdownFrame,
		Button = dropdownButton,
		SelectedText = selectedText,
		List = dropdownList,
		ListLayout = listLayout,
		Options = options,
		SelectedValues = {},
		IsOpen = false,
		Callback = callback,
		OptionButtons = {},
	}

	-- Initialize default values
	for _, val in ipairs(default) do
		multidropdownState.SelectedValues[val] = true
	end

	-- Update selected text display
	local function updateSelectedText()
		local count = 0
		for _, _ in pairs(multidropdownState.SelectedValues) do
			count = count + (1)
		end

		if count > 0 then
			selectedText.Text = (tostring(count) .. " selected")
			selectedText.TextColor3 = Theme.Colors.TextPrimary
		else
			selectedText.Text = "Select..."
			selectedText.TextColor3 = Theme.Colors.TextMuted
		end
	end

	-- Toggle dropdown
	local function toggleDropdown()
		multidropdownState.IsOpen = not multidropdownState.IsOpen

		if multidropdownState.IsOpen then
			-- Open dropdown
			dropdownList.Visible = true
			dropdownList.Size = UDim2.new(1, 0, 0, 0)

			-- Clear existing options
			for _, btn in pairs(multidropdownState.OptionButtons) do
				if btn.Parent then
					btn:Destroy()
				end
			end
			table.clear(multidropdownState.OptionButtons)

			-- Create option buttons
			for i, option in ipairs(options) do
				local optionButton = Instance.new("TextButton")
				optionButton.Name = ("Option_" .. tostring(option))
				optionButton.Size = UDim2.new(1, 0, 0, 28)
				optionButton.BackgroundTransparency = 1
				optionButton.Text = option
				optionButton.TextColor3 = Theme.Colors.TextPrimary
				optionButton.TextSize = Theme.Font.Size.Body
				optionButton.Font = Theme.Font.Family
				optionButton.TextXAlignment = Enum.TextXAlignment.Left
				optionButton.ZIndex = 11

				-- Checkbox indicator
				local checkbox = Instance.new("Frame")
				checkbox.Name = "Checkbox"
				checkbox.Size = UDim2.new(0, 18, 0, 18)
				checkbox.Position = UDim2.new(1, -32, 0.5, -9)
				checkbox.BackgroundColor3 = multidropdownState.SelectedValues[option] and Theme.Colors.AccentPrimary or Theme.Colors.BackgroundTertiary
				checkbox.BackgroundTransparency = multidropdownState.SelectedValues[option] and 0.2 or Theme.Transparency.BackgroundTertiary
				checkbox.ZIndex = 12
				checkbox.ClipsDescendants = true

				local checkboxCorner = Utils.CreateCorner(4, checkbox)

				-- Checkmark icon
				local checkmark = nil
				if multidropdownState.SelectedValues[option] then
					checkmark = Icons.Create(
						"check",
						checkbox,
						UDim2.new(0, 12, 0, 12),
						UDim2.new(0.5, -6, 0.5, -6),
						Theme.Colors.AccentPrimary,
						0
					)
				end

				checkbox.Parent = optionButton

				optionButton.Parent = dropdownList
				table.insert(multidropdownState.OptionButtons, optionButton)

				-- Hover effect
				optionButton.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						Utils.Tween(optionButton, {
							BackgroundColor3 = Theme.Colors.BackgroundHover,
							BackgroundTransparency = Theme.Transparency.BackgroundHover,
						}, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					end
				end)

				optionButton.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						Utils.Tween(optionButton, {
							BackgroundColor3 = Theme.Colors.BackgroundSecondary,
							BackgroundTransparency = Theme.Transparency.BackgroundSecondary,
						}, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					end
				end)

				-- Click handler
				optionButton.MouseButton1Click:Connect(function()
					if multidropdownState.SelectedValues[option] then
						multidropdownState.SelectedValues[option] = nil
					else
						multidropdownState.SelectedValues[option] = true
					end

					-- Update checkbox
					local isSelected = multidropdownState.SelectedValues[option]
					checkbox.BackgroundColor3 = isSelected and Theme.Colors.AccentPrimary or Theme.Colors.BackgroundTertiary
					checkbox.BackgroundTransparency = isSelected and 0.2 or Theme.Transparency.BackgroundTertiary

					if isSelected and not checkmark then
						checkmark = Icons.Create(
							"check",
							checkbox,
							UDim2.new(0, 12, 0, 12),
							UDim2.new(0.5, -6, 0.5, -6),
							Theme.Colors.AccentPrimary,
							0
						)
					elseif not isSelected and checkmark then
						checkmark:Destroy()
						checkmark = nil
					end

					-- Update selected text
					updateSelectedText()

					-- Build selected values list
					local selectedList = {}
					for val, _ in pairs(multidropdownState.SelectedValues) do
						table.insert(selectedList, val)
					end

					-- Callback
					task.spawn(callback, selectedList)
				end)
			end

			-- Animate open
			task.wait(0.01)
			dropdownList.Size = UDim2.new(1, 0, 0, math.clamp(#options * 32, 0, 200))

			-- Rotate arrow
			Utils.Tween(arrowIcon, {
				Rotation = 180,
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		else
			-- Close dropdown
			Utils.Tween(dropdownList, {
				Size = UDim2.new(1, 0, 0, 0),
				Transparency = 1,
			}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

			-- Rotate arrow back
			Utils.Tween(arrowIcon, {
				Rotation = 0,
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			task.delay(0.2, function()
				dropdownList.Visible = false

				-- Clear options
				for _, btn in pairs(multidropdownState.OptionButtons) do
					if btn.Parent then
						btn:Destroy()
					end
				end
				table.clear(multidropdownState.OptionButtons)
			end)
		end
	end

	-- Click handler
	dropdownButton.MouseButton1Click:Connect(toggleDropdown)

	-- MultiDropdown methods
	function multidropdownState:SetOptions(newOptions: {string})
		multidropdownState.Options = newOptions
	end

	function multidropdownState:SetValue(values: {string})
		multidropdownState.SelectedValues = {}
		for _, val in ipairs(values) do
			multidropdownState.SelectedValues[val] = true
		end
		updateSelectedText()
	end

	function multidropdownState:GetValue(): {string}
		local selectedList = {}
		for val, _ in pairs(multidropdownState.SelectedValues) do
			table.insert(selectedList, val)
		end
		return selectedList
	end

	function multidropdownState:SetCallback(newCallback: ({string}) -> ())
		multidropdownState.Callback = newCallback
	end

	function multidropdownState:Open()
		if not multidropdownState.IsOpen then
			toggleDropdown()
		end
	end

	function multidropdownState:Close()
		if multidropdownState.IsOpen then
			toggleDropdown()
		end
	end

	function multidropdownState:Destroy()
		if multidropdownState.IsOpen then
			toggleDropdown()
		end

		Utils.Tween(multidropdownFrame, {
			Transparency = 1,
			Size = UDim2.new(0.5, 0, 0, 0),
			Position = UDim2.new(0.25, 0, 0.5, 0),
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.2, function()
			multidropdownFrame:Destroy()
		end)
	end

	-- Parent multidropdown
	multidropdownFrame.Parent = parent

	return multidropdownState
end

return MultiDropdown