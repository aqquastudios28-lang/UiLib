-- QwenUILib Keybind Component
-- Keybind listeners

local Keybind = {}
Keybind.__index = Keybind

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)
local UserInputService = game:GetService("UserInputService")

-- Create a keybind
function Keybind.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local text = config.Text or "Keybind"
	local default = config.Default or Enum.KeyCode.Unknown
	local callback = config.Callback or function() end
	local mode = config.Mode or "Toggle" -- "Toggle" or "Hold"

	if not parent then
		error("Keybind requires a parent frame")
	end

	-- Main keybind container
	local keybindFrame = Instance.new("Frame")
	keybindFrame.Name = ("Keybind_" .. tostring(text))
	keybindFrame.Size = UDim2.new(1, 0, 0, 36)
	keybindFrame.BackgroundTransparency = 1
	keybindFrame.ZIndex = 2

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

	textLabel.Parent = keybindFrame

	-- Keybind button
	local keybindButton = Instance.new("TextButton")
	keybindButton.Name = "Button"
	keybindButton.Size = UDim2.new(0, 120, 0, 32)
	keybindButton.Position = UDim2.new(1, -120, 0.5, -16)
	keybindButton.BackgroundColor3 = Theme.Colors.BackgroundTertiary
	keybindButton.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
	keybindButton.Text = default ~= Enum.KeyCode.Unknown and default.Name or "Press Key"
	keybindButton.TextColor3 = default ~= Enum.KeyCode.Unknown and Theme.Colors.TextPrimary or Theme.Colors.TextMuted
	keybindButton.TextSize = Theme.Font.Size.Body
	keybindButton.Font = Theme.Font.Family
	keybindButton.ZIndex = 2
	keybindButton.ClipsDescendants = true

	local buttonCorner = Utils.CreateCorner(Theme.CornerRadius.WidgetOuter, keybindButton)
	local buttonStroke = Utils.CreateStroke(keybindButton, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	keybindButton.Parent = keybindFrame

	-- Keybind state
	local keybindState = {
		Frame = keybindFrame,
		Button = keybindButton,
		CurrentKey = default,
		IsListening = false,
		Callback = callback,
		Mode = mode,
		IsActive = false,
	}

	-- Start listening for key
	local function startListening()
		keybindState.IsListening = true
		keybindButton.Text = "Press Key..."
		keybindButton.TextColor3 = Theme.Colors.AccentSecondary

		Utils.Tween(keybindButton, {
			BackgroundColor3 = Theme.Colors.AccentPrimary,
			BackgroundTransparency = 0.3,
		}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end

	-- Stop listening
	local function stopListening()
		keybindState.IsListening = false
		keybindButton.Text = keybindState.CurrentKey ~= Enum.KeyCode.Unknown and keybindState.CurrentKey.Name or "Press Key"
		keybindButton.TextColor3 = keybindState.CurrentKey ~= Enum.KeyCode.Unknown and Theme.Colors.TextPrimary or Theme.Colors.TextMuted

		Utils.Tween(keybindButton, {
			BackgroundColor3 = Theme.Colors.BackgroundTertiary,
			BackgroundTransparency = Theme.Transparency.BackgroundTertiary,
		}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end

	-- Click handler
	keybindButton.MouseButton1Click:Connect(function()
		if not keybindState.IsListening then
			startListening()
		else
			stopListening()
		end
	end)

	-- Input listener
	local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if keybindState.IsListening and input.KeyCode ~= Enum.KeyCode.Unknown then
			keybindState.CurrentKey = input.KeyCode
			stopListening()
			task.spawn(callback, input.KeyCode)
		elseif not keybindState.IsListening and keybindState.CurrentKey ~= Enum.KeyCode.Unknown then
			if input.KeyCode == keybindState.CurrentKey and not gameProcessed then
				if keybindState.Mode == "Toggle" then
					keybindState.IsActive = not keybindState.IsActive
					task.spawn(callback, keybindState.CurrentKey, keybindState.IsActive)
				elseif keybindState.Mode == "Hold" then
					keybindState.IsActive = true
					task.spawn(callback, keybindState.CurrentKey, true)
				end
			end
		end
	end)

	local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
		if not keybindState.IsListening and keybindState.CurrentKey ~= Enum.KeyCode.Unknown then
			if input.KeyCode == keybindState.CurrentKey and keybindState.Mode == "Hold" then
				keybindState.IsActive = false
				task.spawn(callback, keybindState.CurrentKey, false)
			end
		end
	end)

	-- Hover effects
	keybindButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and not keybindState.IsListening then
			Utils.Tween(keybindButton, {
				BackgroundColor3 = Theme.Colors.BackgroundHover,
				BackgroundTransparency = Theme.Transparency.BackgroundHover,
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)

	keybindButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and not keybindState.IsListening then
			Utils.Tween(keybindButton, {
				BackgroundColor3 = Theme.Colors.BackgroundTertiary,
				BackgroundTransparency = Theme.Transparency.BackgroundTertiary,
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)

	-- Keybind methods
	function keybindState:SetKey(keyCode: Enum.KeyCode)
		keybindState.CurrentKey = keyCode
		keybindButton.Text = keyCode.Name
		keybindButton.TextColor3 = Theme.Colors.TextPrimary
	end

	function keybindState:GetKey(): Enum.KeyCode
		return keybindState.CurrentKey
	end

	function keybindState:SetCallback(newCallback: (Enum.KeyCode, boolean?) -> ())
		keybindState.Callback = newCallback
	end

	function keybindState:SetMode(newMode: string)
		keybindState.Mode = newMode
	end

	function keybindState:IsPressed(): boolean
		return keybindState.IsActive
	end

	function keybindState:Destroy()
		inputConnection:Disconnect()
		inputEndedConnection:Disconnect()

		Utils.Tween(keybindFrame, {
			Transparency = 1,
			Size = UDim2.new(0.5, 0, 0, 0),
			Position = UDim2.new(0.25, 0, 0.5, 0),
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.2, function()
			keybindFrame:Destroy()
		end)
	end

	-- Parent keybind
	keybindFrame.Parent = parent

	return keybindState
end

return Keybind