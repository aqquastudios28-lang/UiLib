-- QwenUILib Notification System
-- Liquid glass toast notifications with snappy Back ease slide-in and progress fills

local Notification = {}
Notification.__index = Notification

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Theme = require(script.Parent.Theme)
local Utils = require(script.Parent.Utils)
local Icons = require(script.Parent.Icons)

-- Active notifications
Notification.Registry = {}
Notification.NextId = 1
Notification._gui = nil

-- Toast geometry: fixed width, stacked bottom-right. Stacking (instead of a
-- single shared spot) keeps simultaneous toasts from overlapping each other.
local TOAST_WIDTH = 320
local TOAST_HEIGHT = 64
local TOAST_MARGIN = 20
local TOAST_SPACING = 76

-- Ordered stack of visible toasts; index 1 is the newest (bottom slot).
Notification.Stack = {}

-- Lazily create (and reuse) a ScreenGui to hold notifications. Toasts are
-- GuiObjects and only render inside a ScreenGui. DisplayOrder above the
-- window gui so toasts are never hidden behind windows.
local function getNotificationGui(): Instance
	if not Notification._gui or not Notification._gui.Parent then
		Notification._gui = Utils.CreateScreenGui("QwenUILib_Notifications", 1000)
	end
	return Notification._gui
end

-- Slot position for stack index i (1 = bottom, older toasts shift upward)
local function slotPosition(index: number): UDim2
	return UDim2.new(
		1,
		-(TOAST_WIDTH + TOAST_MARGIN),
		1,
		-(TOAST_MARGIN + TOAST_HEIGHT) - (index - 1) * TOAST_SPACING
	)
end

-- Re-tween every visible toast into its slot
local function relayoutStack()
	for i, state in ipairs(Notification.Stack) do
		Utils.Tween(state.Container, {
			Position = slotPosition(i),
		}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end
end

local function removeFromStack(state)
	for i, existing in ipairs(Notification.Stack) do
		if existing == state then
			table.remove(Notification.Stack, i)
			break
		end
	end
	relayoutStack()
end

-- Notification types with semantic colors
Notification.Types = {
	Info = { Color = Theme.Colors.Info, Icon = "info" },
	Success = { Color = Theme.Colors.Success, Icon = "check-circle" },
	Warning = { Color = Theme.Colors.Warning, Icon = "warning-circle" },
	Error = { Color = Theme.Colors.Error, Icon = "x-circle" },
}

-- Create a new notification
function Notification.Create(message: string, type: string?, parent: Instance?)
	type = type or "Info"
	local notifData = Notification.Types[type] or Notification.Types.Info

	-- Only honor an explicit Instance parent; anything else (nil or a window
	-- state table) falls back to the shared notification ScreenGui.
	if typeof(parent) ~= "Instance" then
		parent = getNotificationGui()
	end

	-- Main container (fixed-width toast, bottom-right)
	local container = Instance.new("Frame")
	container.Name = ("Notification_" .. tostring(Notification.NextId))
	container.Size = UDim2.new(0, TOAST_WIDTH, 0, TOAST_HEIGHT)
	container.Position = UDim2.new(1, -(TOAST_WIDTH + TOAST_MARGIN), 1, 100)
	container.BackgroundColor3 = Theme.Colors.BackgroundSecondary
	container.BackgroundTransparency = Theme.Transparency.BackgroundSecondary
	container.ZIndex = 100

	local containerCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetOuter, container)
	local containerStroke = Utils.CreateStroke(container, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	-- Glass overlay
	local glass = Instance.new("Frame")
	glass.Name = "Glass"
	glass.Size = UDim2.new(1, 0, 1, 0)
	glass.Position = UDim2.new(0, 0, 0, 0)
	glass.BackgroundColor3 = Color3.new(1, 1, 1)
	glass.BackgroundTransparency = 0.93
	glass.ZIndex = 1

	local glassCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetInner, glass)
	glass.Parent = container

	-- Glow left bar
	local glowBar = Instance.new("Frame")
	glowBar.Name = "GlowBar"
	glowBar.Size = UDim2.new(0, 4, 1, 0)
	glowBar.Position = UDim2.new(0, 0, 0, 0)
	glowBar.BackgroundColor3 = notifData.Color
	glowBar.BackgroundTransparency = 0.2
	glowBar.ZIndex = 2

	local glowCorner = Utils.CreateCorner(2, glowBar)
	glowBar.Parent = container

	-- Icon pill
	local iconPill = Icons.CreatePill(
		notifData.Icon,
		container,
		36,
		notifData.Color,
		0.85,
		"Filled"
	)
	iconPill.Position = UDim2.new(0, 12, 0.5, -18)
	iconPill.ZIndex = 3

	-- Message text
	local messageText = Instance.new("TextLabel")
	messageText.Name = "Message"
	messageText.Size = UDim2.new(1, -100, 1, -12)
	messageText.Position = UDim2.new(0, 58, 0, 6)
	messageText.BackgroundTransparency = 1
	messageText.Text = message
	messageText.TextColor3 = Theme.Colors.TextPrimary
	messageText.TextSize = Theme.Font.Size.Body
	messageText.Font = Theme.Font.Family
	messageText.TextWrapped = true
	messageText.TextXAlignment = Enum.TextXAlignment.Left
	messageText.TextYAlignment = Enum.TextYAlignment.Center
	messageText.ZIndex = 3

	messageText.Parent = container

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 24, 0, 24)
	closeButton.Position = UDim2.new(1, -32, 0.5, -12)
	closeButton.BackgroundTransparency = 1
	closeButton.Text = ""
	closeButton.ZIndex = 3

	local closeIcon = Icons.Create(
		"x",
		closeButton,
		UDim2.new(0, 16, 0, 16),
		UDim2.new(0.5, -8, 0.5, -8),
		Theme.Colors.TextMuted,
		0.6
	)

	closeButton.Parent = container

	-- Progress bar
	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.new(1, 0, 0, 3)
	progressBar.Position = UDim2.new(0, 0, 1, -3)
	progressBar.BackgroundColor3 = Theme.Colors.BorderPrimary
	progressBar.BackgroundTransparency = Theme.Transparency.Border
	progressBar.ZIndex = 3

	local progressCorner = Utils.CreateCorner(1, progressBar)
	progressBar.Parent = container

	local progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	progressFill.Size = UDim2.new(0, 0, 1, 0)
	progressFill.Position = UDim2.new(0, 0, 0, 0)
	progressFill.BackgroundColor3 = notifData.Color
	progressFill.BackgroundTransparency = 0.3
	progressFill.ZIndex = 4

	local fillCorner = Utils.CreateCorner(1, progressFill)
	progressFill.Parent = progressBar

	-- Parent container
	container.Parent = parent

	-- Notification state
	local notifState = {
		Container = container,
		MessageText = messageText,
		ProgressFill = progressFill,
		Id = Notification.NextId,
		Type = type,
		Duration = 4,
		StartTime = os.clock(),
	}

	-- Take the bottom slot; older toasts get pushed up by relayoutStack so
	-- toasts never sit on top of each other.
	table.insert(Notification.Stack, 1, notifState)
	relayoutStack()

	-- Slide-in animation (using Back ease for snappy feel)
	Utils.Tween(container, {
		Position = slotPosition(1),
	}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- Close functionality
	local isClosed = false
	local function close()
		if isClosed then
			return
		end
		isClosed = true

		-- Free the slot so the remaining toasts settle down
		removeFromStack(notifState)

		-- Slide out to the right
		Utils.Tween(container, {
			Position = UDim2.new(1, TOAST_MARGIN, 1, container.Position.Y.Offset),
		}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.3, function()
			container:Destroy()
			Notification.Registry[notifState] = nil
		end)
	end

	closeButton.MouseButton1Click:Connect(close)

	-- Auto-close after duration
	task.delay(notifState.Duration, function()
		if notifState.Container and notifState.Container.Parent then
			close()
		end
	end)

	-- Hover pause/resume
	local isPaused = false
	local elapsedBeforePause = 0

	container.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			-- Pause
			isPaused = true
			elapsedBeforePause = os.clock() - notifState.StartTime
		end
	end)

	container.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			-- Resume
			isPaused = false
			notifState.StartTime = os.clock() - elapsedBeforePause
		end
	end)

	-- Update progress animation to respect pause
	-- Declared first so the closure below can reference it to self-disconnect;
	-- `local x = expr` would not have x in scope inside expr.
	local progressConnection
	progressConnection = RunService.Heartbeat:Connect(function()
		if isPaused then
			-- Keep progress bar at current size while paused
			return
		end

		local elapsed = os.clock() - notifState.StartTime
		local progress = math.clamp(elapsed / notifState.Duration, 0, 1)
		progressFill.Size = UDim2.new(progress, 0, 1, 0)

		if progress >= 1 then
			progressConnection:Disconnect()
		end
	end)

	notifState.ProgressConnection = progressConnection

	-- Register notification
	Notification.Registry[notifState] = notifState
	Notification.NextId = Notification.NextId + (1)

	return notifState
end

-- Dismiss all notifications
function Notification.DismissAll()
	for notifState, _ in pairs(Notification.Registry) do
		if notifState.Container and notifState.Container.Parent then
			notifState.Container:Destroy()
		end
	end
	table.clear(Notification.Registry)
	table.clear(Notification.Stack)
end

-- Dismiss specific notification by ID
function Notification.Dismiss(id: number)
	for notifState, _ in pairs(Notification.Registry) do
		if notifState.Id == id then
			if notifState.Container and notifState.Container.Parent then
				notifState.Container:Destroy()
			end
			Notification.Registry[notifState] = nil
			removeFromStack(notifState)
			break
		end
	end
end

return Notification