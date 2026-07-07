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

	-- Title text
	local titleText = Instance.new("TextLabel")
	titleText.Name = "Title"
	titleText.Size = UDim2.new(1, -80, 1, 0)
	titleText.Position = UDim2.new(0, 16, 0, 0)
	titleText.BackgroundTransparency = 1
	titleText.Text = title
	titleText.TextColor3 = Theme.Colors.TextPrimary
	titleText.TextSize = Theme.Font.Size.Title
	titleText.Font = Theme.Font.Family
	titleText.TextXAlignment = Enum.TextXAlignment.Left
	titleText.ZIndex = 3

	titleText.Parent = titleBar

	-- Search bar (optional)
	local searchFrame = nil
	local searchInput = nil

	if config.SearchEnabled then
		searchFrame = Instance.new("Frame")
		searchFrame.Name = "SearchFrame"
		searchFrame.Size = UDim2.new(0, 180, 0, 28)
		searchFrame.Position = UDim2.new(1, -200, 0.5, -14)
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

	-- Content container
	local contentContainer = Instance.new("ScrollingFrame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, 0, 1, -40)
	contentContainer.Position = UDim2.new(0, 0, 0, 40)
	contentContainer.BackgroundTransparency = 1
	contentContainer.ScrollBarThickness = 4
	contentContainer.ScrollBarImageColor3 = Theme.Colors.AccentPrimary
	contentContainer.ScrollBarImageTransparency = 0.5
	contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	Utils.AutoCanvasY(contentContainer)
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

	-- Window methods
	function windowState:AddTab(tabName: string, icon: string?)
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

		tabData.Content.Parent = contentContainer

		return tabData
	end

	function windowState:SwitchTab(tabName: string)
		-- Hide all tabs
		for _, child in ipairs(contentContainer:GetChildren()) do
			if child.Name:match("^Tab_") then
				child.Visible = false
			end
		end

		-- Show selected tab
		local targetTab = contentContainer:FindFirstChild(("Tab_" .. tostring(tabName)))
		if targetTab then
			targetTab.Visible = true

			-- Staggered reveal animation (slide up into place).
			-- Note: GuiObject has no Transparency property, so we only animate
			-- Position, which is valid on every GuiObject.
			for i, child in ipairs(targetTab:GetChildren()) do
				if child:IsA("GuiObject") then
					local basePos = child.Position
					child.Position = UDim2.new(basePos.X.Scale, basePos.X.Offset, basePos.Y.Scale, basePos.Y.Offset + 10)

					task.delay(i * 0.03, function()
						Utils.Tween(child, {
							Position = basePos,
						}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					end)
				end
			end
		end
	end

	function windowState:Destroy()
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