-- src/core/utils.lua
local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.theme)

local Utils = {}

-- Enhanced Tween with theme defaults
function Utils.Tween(obj, time, props)
    time = time or Theme.TweenTime
    local info = TweenInfo.new(time, Theme.EasingStyle, Theme.EasingDirection)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

-- Create rounded corners
function Utils.Corner(obj, radius)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

-- Create glass border with gradient for realistic glass refraction
function Utils.GlassBorder(obj, thickness)
    thickness = thickness or 1
    
    local stroke = Instance.new("UIStroke", obj)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness
    stroke.Transparency = 0.5
    
    local gradient = Instance.new("UIGradient", stroke)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.4, Theme.GlassBorder),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),  -- Glowing top edge highlight
        NumberSequenceKeypoint.new(0.4, 0.7), -- Glass border default
        NumberSequenceKeypoint.new(1, 0.9)   -- Darker bottom edge shadow
    })
    gradient.Rotation = 45
    
    return stroke
end

-- Create glass effect (layered transparency + gradient)
function Utils.CreateGlass(parent, size, position, transparency)
    transparency = transparency or Theme.GlassTransparency
    
    -- Base glass layer
    local glass = Instance.new("Frame", parent)
    glass.Size = size or UDim2.new(1, 0, 1, 0)
    glass.Position = position or UDim2.new(0, 0, 0, 0)
    glass.BackgroundColor3 = Theme.Glass
    glass.BackgroundTransparency = transparency
    glass.BorderSizePixel = 0
    glass.ZIndex = 1
    
    -- Gradient overlay for depth
    local gradient = Instance.new("UIGradient", glass)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 220, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 180))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.92),
        NumberSequenceKeypoint.new(0.5, 0.96),
        NumberSequenceKeypoint.new(1, 0.88)
    })
    gradient.Rotation = 45
    
    Utils.Corner(glass, 8)
    Utils.GlassBorder(glass, 1)
    
    return glass
end

-- Create soft shadow
function Utils.CreateShadow(parent, size, offset, transparency)
    local shadow = Instance.new("Frame", parent)
    shadow.Size = size or UDim2.new(1, 10, 1, 10)
    shadow.Position = offset or UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Theme.ShadowColor
    shadow.BackgroundTransparency = transparency or Theme.ShadowTransparency
    shadow.ZIndex = parent.ZIndex - 1
    Utils.Corner(shadow, 12)
    
    -- Blur effect
    local blur = Instance.new("ImageLabel", shadow)
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundTransparency = 1
    blur.Image = "rbxassetid://5554236805" -- Soft blur texture
    blur.ImageColor3 = Theme.ShadowColor
    blur.ImageTransparency = 0.65
    blur.ScaleType = Enum.ScaleType.Slice
    blur.SliceCenter = Rect.new(23, 23, 277, 277)
    
    return shadow
end

-- Create glowing background blob for liquid neon effect
function Utils.CreateGlowBlob(parent, color, size, position)
    local blob = Instance.new("ImageLabel", parent)
    blob.Size = size or UDim2.new(0, 250, 0, 250)
    blob.Position = position or UDim2.new(0, 0, 0, 0)
    blob.BackgroundTransparency = 1
    blob.Image = "rbxassetid://5554236805" -- Soft blur texture
    blob.ImageColor3 = color
    blob.ImageTransparency = Theme.BlobTransparency
    blob.ZIndex = 0
    return blob
end

-- Make frame draggable with smooth physics
function Utils.MakeDraggable(frame, dragObj)
    local UIS = game:GetService("UserInputService")
    local dragging, dragStart, startPos
    local dragConnection, endConnection

    dragObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            -- Lift effect (scale up + glow highlight)
            Utils.Tween(frame, 0.2, {
                Size = UDim2.new(
                    frame.Size.X.Scale, frame.Size.X.Offset + 4,
                    frame.Size.Y.Scale, frame.Size.Y.Offset + 4
                )
            })
            
            dragConnection = UIS.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    local delta = moveInput.Position - dragStart
                    frame.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end)
            
            endConnection = UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    if dragConnection then
                        dragConnection:Disconnect()
                        dragConnection = nil
                    end
                    if endConnection then
                        endConnection:Disconnect()
                        endConnection = nil
                    end
                    Utils.Tween(frame, 0.2, {
                        Size = UDim2.new(
                            frame.Size.X.Scale, frame.Size.X.Offset - 4,
                            frame.Size.Y.Scale, frame.Size.Y.Offset - 4
                        )
                    })
                end
            end)
        end
    end)
end

-- Create hover effect
function Utils.HoverEffect(obj, hoverColor, normalColor)
    hoverColor = hoverColor or Theme.GlassLight
    normalColor = normalColor or Theme.Glass
    
    obj.MouseEnter:Connect(function()
        Utils.Tween(obj, 0.15, {BackgroundColor3 = hoverColor, BackgroundTransparency = 0.6})
    end)
    
    obj.MouseLeave:Connect(function()
        Utils.Tween(obj, 0.15, {BackgroundColor3 = normalColor, BackgroundTransparency = 0.75})
    end)
end

-- Style custom scrollbar
function Utils.StyleScroll(scroll)
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Accent
    scroll.ScrollBarImageTransparency = 0.5
    scroll.BorderSizePixel = 0
end

return Utils