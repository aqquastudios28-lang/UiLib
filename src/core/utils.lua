-- QwenUILib Utilities
-- Corner curves, UIStroke borders, MakeDraggable, CreateShadow, CreateGlowBlob, Tween

local Utils = {}
Utils.__index = Utils

-- Tween utility with spring physics
function Utils.Tween(object: Instance, properties: table, duration: number, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?): Tween
	local tweenService = game:GetService("TweenService")

	easingStyle = easingStyle or Enum.EasingStyle.Quart
	easingDirection = easingDirection or Enum.EasingDirection.Out

	local tweenInfo = TweenInfo.new(
		duration,
		easingStyle,
		easingDirection
	)

	local tween = tweenService:Create(object, tweenInfo, properties)
	tween:Play()

	return tween
end

-- Create rounded corner with precise radius
function Utils.CreateCorner(radius: number, parent: Instance?): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	if parent then
		corner.Parent = parent
	end
	return corner
end

-- Create UIStroke (border) with customizable properties
function Utils.CreateStroke(
	parent: Instance,
	color: Color3?,
	thickness: number?,
	transparency: number?,
	cornerRadius: number?
): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromHex("#3f3f46")
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0.8
	stroke.LineJoinMode = Enum.LineJoinMode.Round

	if cornerRadius then
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local corner = Utils.CreateCorner(cornerRadius, parent)
	end

	stroke.Parent = parent
	return stroke
end

-- Make a frame draggable from its title bar
function Utils.MakeDraggable(frame: Frame, dragHandle: Frame?)
	local dragTarget = dragHandle or frame
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	local function updatePosition(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	dragTarget.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragTarget.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			updatePosition(input)
		end
	end)

	return frame
end

-- Create drop shadow effect
function Utils.CreateShadow(parent: Instance, size: number?, transparency: number?): Frame
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, size or 20, 1, size or 20)
	shadow.Position = UDim2.new(0, -(size or 20) / 2, 0, -(size or 20) / 2)
	shadow.BackgroundTransparency = 1
	shadow.ZIndex = parent.ZIndex - 1

	local image = Instance.new("ImageLabel")
	image.Name = "ShadowImage"
	image.Size = UDim2.new(1, 0, 1, 0)
	image.Position = UDim2.new(0, 0, 0, 0)
	image.BackgroundTransparency = 1
	image.Image = "rbxassetid://6403377997" -- Generic shadow texture
	image.ImageColor3 = Color3.fromHex("#000000")
	image.ImageTransparency = transparency or 0.5
	image.ScaleType = Enum.ScaleType.Slice
	image.SliceCenter = Rect.new(50, 50, 50, 50)
	image.SliceScale = 2

	image.Parent = shadow
	shadow.Parent = parent

	return shadow
end

-- Create animated glow blob (for glass morphism effects)
function Utils.CreateGlowBlob(
	parent: Instance,
	color: Color3?,
	size: number?,
	position: UDim2?
): Frame
	local blob = Instance.new("Frame")
	blob.Name = "GlowBlob"
	blob.Size = UDim2.new(0, size or 200, 0, size or 200)
	blob.Position = position or UDim2.new(0.5, -100, 0.5, -100)
	blob.BackgroundColor3 = color or Color3.fromHex("#7c3aed")
	blob.BackgroundTransparency = 0.85
	blob.ZIndex = 1

	local corner = Utils.CreateCorner(50, blob)
	local blur = Instance.new("BlurEffect")
	blur.Size = 64
	blur.Parent = blob

	blob.Parent = parent

	-- Animate blob with gentle floating motion
	local runService = game:GetService("RunService")
	local startTime = os.clock()

	local connection = runService.Heartbeat:Connect(function()
		local elapsed = os.clock() - startTime
		blob.Position = UDim2.new(
			0.5 + math.sin(elapsed * 0.5) * 0.1,
			-size / 2,
			0.5 + math.cos(elapsed * 0.3) * 0.1,
			-size / 2
		)
	end)

	blob:GetPropertyChangedSignal("Parent"):Connect(function()
		if not blob.Parent then
			connection:Disconnect()
		end
	end)

	return blob
end

-- Create UIListLayout with customizable settings
function Utils.CreateListLayout(
	parent: Instance,
	horizontal: boolean?,
	padding: number?,
	align: Enum.FlexAlignment?
): UIListLayout
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = if horizontal then Enum.FillDirection.Horizontal else Enum.FillDirection.Vertical
	layout.HorizontalAlignment = align or Enum.FlexAlignment.Center
	layout.VerticalAlignment = align or Enum.FlexAlignment.Center
	layout.Padding = UDim.new(0, padding or 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = parent

	return layout
end

-- Create UIPadding with customizable insets
function Utils.CreatePadding(
	parent: Instance,
	top: number?,
	bottom: number?,
	left: number?,
	right: number?
): UIPadding
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.Parent = parent

	return padding
end

-- Create UIScale for responsive scaling
function Utils.CreateScale(parent: Instance, scale: number?): UIScale
	local scaleObj = Instance.new("UIScale")
	scaleObj.Scale = scale or 1
	scaleObj.Parent = parent

	return scaleObj
end

-- Apply theme colors to a frame
function Utils.ApplyTheme(
	frame: Frame,
	backgroundColor: Color3?,
	backgroundTransparency: number?,
	cornerRadius: number?
): Frame
	if backgroundColor then
		frame.BackgroundColor3 = backgroundColor
	end
	if backgroundTransparency then
		frame.BackgroundTransparency = backgroundTransparency
	end
	if cornerRadius then
		local corner = Utils.CreateCorner(cornerRadius, frame)
	end

	return frame
end

-- Clamp a value between min and max
function Utils.Clamp(value: number, min: number, max: number): number
	return math.clamp(value, min, max)
end

-- Linear interpolation
function Utils.Lerp(start: number, goal: number, alpha: number): number
	return start + (goal - start) * alpha
end

-- Map a value from one range to another
function Utils.Map(value: number, inMin: number, inMax: number, outMin: number, outMax: number): number
	return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

-- Debounce a function
function Utils.Debounce(func: any, delay: number): any
	local running = false
	return function(...)
		if not running then
			running = true
			task.delay(delay, function()
				running = false
				func(...)
			end)
		end
	end
end

-- Throttle a function
function Utils.Throttle(func: any, limit: number): any
	local lastExecution = 0
	return function(...)
		local now = os.clock()
		if now - lastExecution >= limit then
			lastExecution = now
			func(...)
		end
	end
end

-- Deep merge tables
function Utils.DeepMerge(original: table, new: table): table
	for key, value in pairs(new) do
		if type(value) == "table" and type(original[key]) == "table" then
			Utils.DeepMerge(original[key], value)
		else
			original[key] = value
		end
	end
	return original
end

-- Create safe wrapper for cleanup
function Utils.CreateCleanupWrapper(object: Instance, cleanupFunc: () -> ())
	local mt = {
		__gc = function()
			cleanupFunc()
		end,
	}

	if typeof(object) == "Instance" then
		object:GetPropertyChangedSignal("Parent"):Connect(function()
			if not object.Parent then
				cleanupFunc()
			end
		end)
	end

	return setmetatable({}, mt)
end

return Utils