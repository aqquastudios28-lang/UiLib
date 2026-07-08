-- QwenUILib Window Manager
-- Outer/Inner concentric frames, title bar drag, search filters, TabGroups, Tabs, SubTabs

local Window = {}
Window.__index = Window

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)
local Icons = require(script.Parent.Parent.Icons)

-- Active windows registry
Window.Registry = {}
Window.ActiveWindow = nil

-- Create a new window
function Window.Create(config: table)
	config = config or {}
	local title = config.Title or "QwenUI Window"
	local width = config.Width or 600
	local height = config.Height or 400
	local minWidth = config.MinWidth or 400
	local minHeight = config.MinHeight or 300

	-- A GuiObject only renders inside a ScreenGui. When no explicit parent is
	-- given, create one and mount it in a protected container (gethui/CoreGui).
	local screenGui = nil
	local parent = config.Parent
	if not parent then
		screenGui = Utils.CreateScreenGui("QwenUILib")
		parent = screenGui
	end

	-- Main outer frame (Doppelrand - Concentric Double-Bezel)
	local outerFrame = Instance.new("Frame")
	outerFrame.Name = "QwenWindow_Outer"
	outerFrame.Size = UDim2.new(0, width, 0, height)
	outerFrame.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
	outerFrame.BackgroundColor3 = Theme.Colors.BackgroundPrimary
	outerFrame.BackgroundTransparency = Theme.Transparency.BackgroundPrimary
	outerFrame.ZIndex = 1
	outerFrame.ClipsDescendants = true

	-- Glass border stroke for outer
	local outerStroke = Utils.CreateStroke(outerFrame, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Stroke)
	local outerCorner = Utils.CreateCorner(Theme.CornerRadius.WindowOuter, outerFrame)

	-- Inner core frame
	local innerFrame = Instance.new("Frame")
	innerFrame.Name = "QwenWindow_Inner"
	innerFrame.Size = UDim2.new(1, -12, 1, -12)
	innerFrame.Position = UDim2.new(0, 6, 0, 6)
	innerFrame.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	innerFrame.BackgroundTransparency = Theme.Transparency.BackgroundSecondary
	innerFrame.ZIndex = 1
	innerFrame.ClipsDescendants = true

	local innerCorner = Utils.CreateCorner(Theme.CornerRadius.WindowInner, innerFrame)
	local innerStroke = Utils.CreateStroke(innerFrame, Theme.Colors.BorderSecondary, 1, Theme.Transparency.Border)

	innerFrame.Parent = outerFrame

	-- Glass overlay for morphism effects
	local glassOverlay = Instance.new("Frame")
	glassOverlay.Name = "GlassOverlay"
	glassOverlay.Size = UDim2.new(1, 0, 1, 0)
	glassOverlay.Position = UDim2.new(0, 0, 0, 0)
	glassOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
	glassOverlay.BackgroundTransparency = 0.95
	glassOverlay.ZIndex = 1

	local glassCorner = Utils.CreateCorner(Theme.CornerRadius.WindowInner, glassOverlay)
	glassOverlay.Parent = innerFrame

	-- Optional glow blob for premium effect
	local glowBlob = Utils.CreateGlowBlob(
		innerFrame,
		Theme.Colors.AccentPrimary,
		300,
		UDim2.new(0.5, -150, 0.3, -150)
	)

	-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundTransparency = 1
	titleBar.ZIndex = 3

	local titleCorner = Utils.CreateCorner(Theme.CornerRadius.WindowInner, titleBar)
	titleBar.Parent = innerFrame

	-- Title text (leave room for the window controls, and the search box when
	-- it is enabled)
	local titleText = Instance.new("TextLabel")
	titleText.Name = "Title"
	titleText.Size = UDim2.new(1, config.SearchEnabled and -282 or -96, 1, 0)
	titleText.Position = UDim2.new(0, 16, 0, 0)
	titleText.BackgroundTransparency = 1
	titleText.Text = title
	titleText.TextColor3 = Theme.Colors.TextPrimary
	titleText.TextSize = Theme.Font.Size.Title
	titleText.Font = Theme.Font.Family
	titleText.TextXAlignment = Enum.TextXAlignment.Left
	titleText.ZIndex = 3

	titleText.Parent = titleBar

	-- Window controls: minimize + close, top-right of the title bar
	local function makeTitleButton(name, xOffset)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = UDim2.new(0, 24, 0, 24)
		button.Position = UDim2.new(1, xOffset, 0.5, -12)
		button.BackgroundColor3 = Theme.Colors.BackgroundTertiary
		button.BackgroundTransparency = 1
		button.Text = ""
		button.ZIndex = 4
		Utils.CreateCorner(Theme.CornerRadius.Small, button)
		button.Parent = titleBar
		return button
	end

	local closeButton = makeTitleButton("CloseButton", -36)
	local closeIcon = Icons.Create(
		"x",
		closeButton,
		UDim2.new(0, 14, 0, 14),
		UDim2.new(0.5, -7, 0.5, -7),
		Theme.Colors.TextMuted,
		0.4
	)
	closeIcon.ZIndex = 4

	local minimizeButton = makeTitleButton("MinimizeButton", -64)
	local minimizeIcon = Icons.Create(
		"minus",
		minimizeButton,
		UDim2.new(0, 14, 0, 14),
		UDim2.new(0.5, -7, 0.5, -7),
		Theme.Colors.TextMuted,
		0.4
	)
	minimizeIcon.ZIndex = 4

	-- Hover feedback: close tints red, minimize lightens
	local function wireTitleButtonHover(button, hoverColor)
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				Utils.Tween(button, {
					BackgroundColor3 = hoverColor,
					BackgroundTransparency = 0.4,
				}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			end
		end)
		button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				Utils.Tween(button, {
					BackgroundTransparency = 1,
				}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			end
		end)
	end

	wireTitleButtonHover(closeButton, Theme.Colors.Error)
	wireTitleButtonHover(minimizeButton, Theme.Colors.BackgroundHover)

	-- Search bar (optional; sits left of the window controls)
	local searchFrame = nil
	local searchInput = nil

	if config.SearchEnabled then
		searchFrame = Instance.new("Frame")
		searchFrame.Name = "SearchFrame"
		searchFrame.Size = UDim2.new(0, 180, 0, 28)
		searchFrame.Position = UDim2.new(1, -252, 0.5, -14)
		searchFrame.BackgroundColor3 = Theme.Colors.BackgroundTertiary
		searchFrame.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
		searchFrame.ZIndex = 3

		local searchCorner = Utils.CreateCorner(Theme.CornerRadius.Small, searchFrame)
		local searchStroke = Utils.CreateStroke(searchFrame, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

		searchFrame.Parent = titleBar

		searchInput = Instance.new("TextBox")
		searchInput.Name = "SearchInput"
		searchInput.Size = UDim2.new(1, -32, 1, 0)
		searchInput.Position = UDim2.new(0, 8, 0, 0)
		searchInput.BackgroundTransparency = 1
		searchInput.PlaceholderText = "Search..."
		searchInput.Text = ""
		searchInput.TextColor3 = Theme.Colors.TextPrimary
		searchInput.PlaceholderColor3 = Theme.Colors.TextMuted
		searchInput.TextSize = Theme.Font.Size.Body
		searchInput.Font = Theme.Font.Family
		searchInput.ZIndex = 3

		searchInput.Parent = searchFrame

		-- Search icon
		local searchIcon = Icons.Create(
			"magnifying-glass",
			searchFrame,
			UDim2.new(0, 16, 0, 16),
			UDim2.new(1, -24, 0.5, -8),
			Theme.Colors.TextMuted,
			0.5
		)
	end

	-- Tab bar (hidden until the first tab is added). A ScrollingFrame so tabs
	-- that overflow the window width stay reachable instead of being clipped.
	local tabBar = Instance.new("ScrollingFrame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, -24, 0, 32)
	tabBar.Position = UDim2.new(0, 12, 0, 40)
	tabBar.BackgroundTransparency = 1
	tabBar.BorderSizePixel = 0
	tabBar.ScrollBarThickness = 2
	tabBar.ScrollBarImageColor3 = Theme.Colors.AccentPrimary
	tabBar.ScrollBarImageTransparency = 0.6
	tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabBar.ClipsDescendants = true
	tabBar.ZIndex = 3
	tabBar.Visible = false
	pcall(function()
		tabBar.ScrollingDirection = Enum.ScrollingDirection.X
	end)
	tabBar.Parent = innerFrame

	local tabBarLayout = Instance.new("UIListLayout")
	tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
	tabBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabBarLayout.Padding = UDim.new(0, 8)
	tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabBarLayout.Parent = tabBar

	-- Keep the tab bar canvas fitted to its buttons
	tabBarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabBar.CanvasSize = UDim2.new(0, tabBarLayout.AbsoluteContentSize.X, 0, 0)
	end)

	-- Content container. Sized for a window without tabs; AddTab shifts it down
	-- to make room for the tab bar.
	local contentContainer = Instance.new("ScrollingFrame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, 0, 1, -40)
	contentContainer.Position = UDim2.new(0, 0, 0, 40)
	contentContainer.BackgroundTransparency = 1
	contentContainer.ScrollBarThickness = 4
	contentContainer.ScrollBarImageColor3 = Theme.Colors.AccentPrimary
	contentContainer.ScrollBarImageTransparency = 0.5
	contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	-- +32 accounts for the content UIPadding (16 top + 16 bottom), which the
	-- layout's AbsoluteContentSize does not include.
	Utils.AutoCanvasY(contentContainer, 32)
	contentContainer.ZIndex = 2
	contentContainer.ClipsDescendants = true

	local contentCorner = Utils.CreateCorner(Theme.CornerRadius.WindowInner, contentContainer)
	contentContainer.Parent = innerFrame

	-- Content padding
	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 16)
	contentPadding.PaddingBottom = UDim.new(0, 16)
	contentPadding.PaddingLeft = UDim.new(0, 16)
	contentPadding.PaddingRight = UDim.new(0, 16)
	contentPadding.Parent = contentContainer

	-- Main layout
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.FillDirection = Enum.FillDirection.Vertical
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	contentLayout.Padding = UDim.new(0, 12)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Parent = contentContainer

	-- Make window draggable
	Utils.MakeDraggable(outerFrame, titleBar)

	-- Window state
	local windowState = {
		ScreenGui = screenGui,
		OuterFrame = outerFrame,
		InnerFrame = innerFrame,
		TitleBar = titleBar,
		TitleText = titleText,
		TabBar = tabBar,
		Tabs = {},
		TabOrder = {},
		ActiveTab = nil,
		ContentContainer = contentContainer,
		ContentLayout = contentLayout,
		SearchFrame = searchFrame,
		SearchInput = searchInput,
		GlassOverlay = glassOverlay,
		GlowBlob = glowBlob,
		Width = width,
		Height = height,
		MinWidth = minWidth,
		MinHeight = minHeight,
		IsOpen = true,
		Config = config,
	}

	-- Tab button styling (active tab is highlighted, inactive tabs are muted)
	local function styleTabButton(button, active)
		if active then
			button.BackgroundColor3 = Theme.Colors.AccentPrimary
			button.BackgroundTransparency = 0.7
			button.TextColor3 = Theme.Colors.TextPrimary
		else
			button.BackgroundColor3 = Theme.Colors.BackgroundTertiary
			button.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
			button.TextColor3 = Theme.Colors.TextMuted
		end
	end

	-- Measure a tab label so buttons fit their text (no AutomaticSize on old
	-- executor clients). Falls back to a per-character estimate.
	local function measureTabWidth(tabName)
		local textWidth = 0
		pcall(function()
			local bounds = game:GetService("TextService"):GetTextSize(
				tabName,
				Theme.Font.Size.Body,
				Theme.Font.Family,
				Vector2.new(1000, 100)
			)
			textWidth = bounds.X
		end)
		if textWidth <= 0 then
			textWidth = #tabName * 8
		end
		return math.ceil(textWidth) + 24
	end

	-- Window methods
	function windowState:AddTab(tabName: string, icon: string?)
		-- First tab: reveal the tab bar and shift content down to clear it.
		if #windowState.TabOrder == 0 then
			tabBar.Visible = true
			contentContainer.Position = UDim2.new(0, 0, 0, 76)
			contentContainer.Size = UDim2.new(1, 0, 1, -76)
		end

		local tabData = {
			Name = tabName,
			Icon = icon,
			Content = Instance.new("Frame"),
			IsActive = false,
		}

		tabData.Content.Name = ("Tab_" .. tostring(tabName))
		tabData.Content.Size = UDim2.new(1, 0, 0, 0)
		tabData.Content.Position = UDim2.new(0, 0, 0, 0)
		tabData.Content.BackgroundTransparency = 1
		tabData.Content.Visible = false
		tabData.Content.ZIndex = 2

		local tabLayout = Instance.new("UIListLayout")
		tabLayout.FillDirection = Enum.FillDirection.Vertical
		tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		tabLayout.Padding = UDim.new(0, 12)
		tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabLayout.Parent = tabData.Content

		-- Grow to fit its widgets so the scroll canvas measures correctly
		-- (manual fallback keeps this working without Enum.AutomaticSize).
		Utils.AutoSizeListY(tabData.Content, tabLayout)

		tabData.Content.Parent = contentContainer

		-- Clickable tab button
		local tabButton = Instance.new("TextButton")
		tabButton.Name = ("TabButton_" .. tostring(tabName))
		tabButton.Size = UDim2.new(0, measureTabWidth(tabName), 0, 26)
		tabButton.Text = tabName
		tabButton.TextSize = Theme.Font.Size.Body
		tabButton.Font = Theme.Font.Family
		tabButton.ZIndex = 3
		tabButton.LayoutOrder = #windowState.TabOrder + 1
		styleTabButton(tabButton, false)

		Utils.CreateCorner(Theme.CornerRadius.Button, tabButton)
		Utils.CreateStroke(tabButton, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

		tabButton.MouseButton1Click:Connect(function()
			windowState:SwitchTab(tabName)
		end)

		tabButton.Parent = tabBar

		tabData.Button = tabButton
		windowState.Tabs[tabName] = tabData
		table.insert(windowState.TabOrder, tabName)

		-- Always have a visible tab: the first one activates itself.
		if #windowState.TabOrder == 1 then
			windowState:SwitchTab(tabName)
		end

		return tabData
	end

	function windowState:SwitchTab(tabName: string)
		local target = windowState.Tabs[tabName]
		if not target then
			return
		end

		-- Hide all tabs, deactivate all buttons
		for _, name in ipairs(windowState.TabOrder) do
			local tab = windowState.Tabs[name]
			tab.IsActive = false
			tab.Content.Visible = false
			styleTabButton(tab.Button, false)
		end

		-- Show selected tab
		target.IsActive = true
		target.Content.Visible = true
		styleTabButton(target.Button, true)
		windowState.ActiveTab = tabName

		-- Reset scroll so the top of the new tab is always in view
		contentContainer.CanvasPosition = Vector2.new(0, 0)
	end

	function windowState:SetVisible(visible: boolean)
		windowState.IsOpen = visible
		outerFrame.Visible = visible
	end

	function windowState:ToggleVisibility()
		windowState:SetVisible(not windowState.IsOpen)
	end

	function windowState:SetMinimized(minimized: boolean)
		windowState.IsMinimized = minimized

		if minimized then
			-- Collapse to the title bar (outer bezel 12 + title 40)
			Utils.Tween(outerFrame, {
				Size = UDim2.new(0, windowState.Width, 0, 52),
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		else
			Utils.Tween(outerFrame, {
				Size = UDim2.new(0, windowState.Width, 0, windowState.Height),
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end

	function windowState:ToggleMinimize()
		windowState:SetMinimized(not windowState.IsMinimized)
	end

	function windowState:Destroy()
		if windowState.ToggleConnection then
			windowState.ToggleConnection:Disconnect()
			windowState.ToggleConnection = nil
		end
		-- Animate out
		Utils.Tween(outerFrame, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
		}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.3, function()
			outerFrame:Destroy()
			if screenGui then
				screenGui:Destroy()
			end
			Window.Registry[windowState] = nil
			if Window.ActiveWindow == windowState then
				Window.ActiveWindow = nil
			end
		end)
	end

	function windowState:SetTitle(newTitle: string)
		windowState.TitleText.Text = newTitle
	end

	function windowState:Notify(message: string, type: string?)
		local Notification = require(script.Parent.Notification)
		Notification.Create(message, type or "Info", windowState)
	end

	-- Wire the window controls
	closeButton.MouseButton1Click:Connect(function()
		windowState:Destroy()
	end)

	minimizeButton.MouseButton1Click:Connect(function()
		windowState:ToggleMinimize()
	end)

	-- Show/hide keybind (default RightShift; pass ToggleKey = false to disable)
	local toggleKey = config.ToggleKey
	if toggleKey == nil then
		toggleKey = Enum.KeyCode.RightShift
	end
	if toggleKey then
		windowState.ToggleKey = toggleKey
		windowState.ToggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode == toggleKey then
				windowState:ToggleVisibility()
			end
		end)
	end

	-- Register window
	Window.Registry[windowState] = windowState
	Window.ActiveWindow = windowState

	-- Parent to provided parent
	outerFrame.Parent = parent

	-- Entrance animation
	outerFrame.Size = UDim2.new(0, 0, 0, 0)
	outerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

	Utils.Tween(outerFrame, {
		Size = UDim2.new(0, width, 0, height),
		Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
	}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	return windowState
end

-- Close all windows
function Window.DestroyAll()
	for windowState, _ in pairs(Window.Registry) do
		windowState:Destroy()
	end
	table.clear(Window.Registry)
	Window.ActiveWindow = nil
end

return Window