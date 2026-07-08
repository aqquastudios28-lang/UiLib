-- QwenUILib Dropdown Component
-- Filterable text search dropdown lists

local Dropdown = {}
Dropdown.__index = Dropdown

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)
local Icons = require(script.Parent.Parent.Icons)

-- Create a dropdown
function Dropdown.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or "Dropdown"
	local options = config.Options or {}
	local default = config.Default or ""
	local callback = config.Callback or function() end

	if not parent then
		error("Dropdown requires a parent frame")
	end

	-- Widget heights. The container expands while the list is open so the
	-- options push the widgets below down instead of overlapping them.
	local CLOSED_HEIGHT = 56

	-- Main dropdown container
	local dropdownFrame = Instance.new("Frame")
	dropdownFrame.Name = ("Dropdown_" .. tostring(text))
	dropdownFrame.Size = UDim2.new(1, 0, 0, CLOSED_HEIGHT)
	dropdownFrame.BackgroundTransparency = 1
	dropdownFrame.ZIndex = 2

	-- Text label (its own row above the button, no overlap)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.new(1, 0, 0, 18)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = Theme.Colors.TextPrimary
	textLabel.TextSize = Theme.Font.Size.Body
	textLabel.Font = Theme.Font.Family
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.ZIndex = 2

	textLabel.Parent = dropdownFrame

	-- Dropdown button
	local dropdownButton = Instance.new("TextButton")
	dropdownButton.Name = "Button"
	dropdownButton.Size = UDim2.new(1, 0, 0, 32)
	dropdownButton.Position = UDim2.new(0, 0, 0, 24)
	dropdownButton.BackgroundColor3 = Theme.Colors.BackgroundTertiary
	dropdownButton.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
	dropdownButton.ZIndex = 2
	dropdownButton.ClipsDescendants = true

	local buttonCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetOuter, dropdownButton)
	local buttonStroke = Utils.CreateStroke(dropdownButton, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	dropdownButton.Parent = dropdownFrame

	-- Selected value text
	local selectedText = Instance.new("TextLabel")
	selectedText.Name = "Selected"
	selectedText.Size = UDim2.new(1, -40, 1, 0)
	selectedText.Position = UDim2.new(0, 12, 0, 0)
	selectedText.BackgroundTransparency = 1
	selectedText.Text = default ~= "" and default or "Select..."
	selectedText.TextColor3 = default ~= "" and Theme.Colors.TextPrimary or Theme.Colors.TextMuted
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

	-- Dropdown list (hidden by default; sits below the button inside the
	-- container, which grows to hold it while open)
	local dropdownList = Instance.new("ScrollingFrame")
	dropdownList.Name = "List"
	dropdownList.Size = UDim2.new(1, 0, 0, 0)
	dropdownList.Position = UDim2.new(0, 0, 0, 60)
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

	dropdownList.Parent = dropdownFrame

	-- List layout
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.Padding = UDim.new(0, 4)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = dropdownList

	-- Inset the options from the list edges
	Utils.CreatePadding(dropdownList, 4, 4, 8, 8)

	-- Dropdown state
	local dropdownState = {
		Frame = dropdownFrame,
		Button = dropdownButton,
		SelectedText = selectedText,
		List = dropdownList,
		ListLayout = listLayout,
		Options = options,
		SelectedValue = default,
		IsOpen = false,
		Callback = callback,
		OptionButtons = {},
	}

	-- Toggle dropdown
	local function toggleDropdown()
		dropdownState.IsOpen = not dropdownState.IsOpen

		if dropdownState.IsOpen then
			-- Open dropdown
			dropdownList.Visible = true
			dropdownList.Size = UDim2.new(1, 0, 0, 0)
			-- Restore the backdrop in case a previous close faded it out
			dropdownList.BackgroundTransparency = Theme.Transparency.BackgroundSecondary

			-- Clear any stale options before rebuilding
			for _, btn in pairs(dropdownState.OptionButtons) do
				if btn.Parent then
					btn:Destroy()
				end
			end
			table.clear(dropdownState.OptionButtons)

			-- Create option buttons
			for i, option in ipairs(dropdownState.Options) do
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
				pcall(function()
					optionButton.TextTruncate = Enum.TextTruncate.AtEnd
				end)

				optionButton.Parent = dropdownList
				table.insert(dropdownState.OptionButtons, optionButton)

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
					dropdownState.SelectedValue = option
					selectedText.Text = option
					selectedText.TextColor3 = Theme.Colors.TextPrimary

					-- Close dropdown
					toggleDropdown()

					-- Callback
					task.spawn(callback, option)
				end)
			end

			-- Animate open: grow the list and the container together so the
			-- widgets below get pushed down (never overlapped)
			local listHeight = math.clamp(#dropdownState.Options * 32 + 4, 40, 168)

			Utils.Tween(dropdownList, {
				Size = UDim2.new(1, 0, 0, listHeight),
			}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			Utils.Tween(dropdownFrame, {
				Size = UDim2.new(1, 0, 0, CLOSED_HEIGHT + listHeight + 8),
			}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			-- Rotate arrow
			Utils.Tween(arrowIcon, {
				Rotation = 180,
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		else
			-- Close dropdown: shrink the list and the container back
			Utils.Tween(dropdownList, {
				Size = UDim2.new(1, 0, 0, 0),
			}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

			Utils.Tween(dropdownFrame, {
				Size = UDim2.new(1, 0, 0, CLOSED_HEIGHT),
			}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

			-- Rotate arrow back
			Utils.Tween(arrowIcon, {
				Rotation = 0,
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			task.delay(0.2, function()
				dropdownList.Visible = false

				-- Clear options
				for _, btn in pairs(dropdownState.OptionButtons) do
					if btn.Parent then
						btn:Destroy()
					end
				end
				table.clear(dropdownState.OptionButtons)
			end)
		end
	end

	-- Click handler
	dropdownButton.MouseButton1Click:Connect(toggleDropdown)

	-- Close when clicking outside
	dropdownButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Add pressed effect
			Utils.Tween(dropdownButton, {
				BackgroundTransparency = 0.5,
			}, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)

	dropdownButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Utils.Tween(dropdownButton, {
				BackgroundTransparency = Theme.Transparency.BackgroundTertiary,
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)

	-- Dropdown methods
	function dropdownState:SetOptions(newOptions: {string})
		dropdownState.Options = newOptions
	end

	function dropdownState:SetValue(value: string)
		dropdownState.SelectedValue = value
		selectedText.Text = value
		selectedText.TextColor3 = Theme.Colors.TextPrimary
	end

	function dropdownState:GetValue(): string
		return dropdownState.SelectedValue
	end

	function dropdownState:SetCallback(newCallback: (string) -> ())
		dropdownState.Callback = newCallback
	end

	function dropdownState:Open()
		if not dropdownState.IsOpen then
			toggleDropdown()
		end
	end

	function dropdownState:Close()
		if dropdownState.IsOpen then
			toggleDropdown()
		end
	end

	function dropdownState:Destroy()
		if dropdownState.IsOpen then
			toggleDropdown()
		end

		Utils.Tween(dropdownFrame, {
			Transparency = 1,
			Size = UDim2.new(0.5, 0, 0, 0),
			Position = UDim2.new(0.25, 0, 0.5, 0),
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.2, function()
			dropdownFrame:Destroy()
		end)
	end

	-- Parent dropdown
	dropdownFrame.Parent = parent

	return dropdownState
end

return Dropdown