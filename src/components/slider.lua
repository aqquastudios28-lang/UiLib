-- src/components/slider.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)
local UIS = game:GetService("UserInputService")

return function(Tab, name, min, max, default, callback)
    min, max, default = min or 0, max or 100, default or 0
    local value = default
    callback = callback or function() end

    -- Main Frame (Glass)
    local Frame = Instance.new("Frame", Tab.Frame)
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundColor3 = Theme.Glass
    Frame.BackgroundTransparency = 0.75
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 2
    Utils.Corner(Frame, 8)
    Utils.GlassBorder(Frame, 0.8)

    -- Label with value display
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 14, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. value
    Label.TextColor3 = Theme.Text
    Label.TextSize = 13
    Label.Font = Theme.Font
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 3

    -- Slider Track (Background)
    local Track = Instance.new("Frame", Frame)
    Track.Size = UDim2.new(1, -28, 0, 6)
    Track.Position = UDim2.new(0, 14, 0, 34)
    Track.BackgroundColor3 = Theme.GlassLight
    Track.BackgroundTransparency = 0.5
    Track.ZIndex = 3
    Utils.Corner(Track, 3)

    -- Slider Fill (Gradient)
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BackgroundTransparency = 0.3
    Fill.ZIndex = 4
    Utils.Corner(Fill, 3)

    -- Fill Gradient
    local FillGradient = Instance.new("UIGradient", Fill)
    FillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 200, 255))
    })

    -- Slider Knob (Glass Circle)
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8)
    Knob.BackgroundColor3 = Theme.Text
    Knob.BackgroundTransparency = 0.1
    Knob.ZIndex = 5
    Utils.Corner(Knob, 8)

    -- Knob Glow
    local KnobGlow = Instance.new("Frame", Knob)
    KnobGlow.Size = UDim2.new(1, 4, 1, 4)
    KnobGlow.Position = UDim2.new(0, -2, 0, -2)
    KnobGlow.BackgroundColor3 = Theme.Accent
    KnobGlow.BackgroundTransparency = 0.8
    KnobGlow.ZIndex = 4
    Utils.Corner(KnobGlow, 10)

    -- Helper to update slider visuals based on raw value
    local function UpdateVisuals(val)
        local pct = (val - min) / (max - min)
        Utils.Tween(Fill, 0.1, {Size = UDim2.new(pct, 0, 1, 0)})
        Utils.Tween(Knob, 0.1, {Position = UDim2.new(pct, -8, 0.5, -8)})
        Label.Text = name .. ": " .. val
    end

    -- Update Function for mouse movement input
    local function UpdateFromPos(x)
        local totalWidth = Track.AbsoluteSize.X
        if totalWidth <= 0 then return end
        
        local rel = math.clamp(x - Track.AbsolutePosition.X, 0, totalWidth)
        local pct = rel / totalWidth
        value = math.floor(min + (max - min) * pct)
        
        UpdateVisuals(value)
        task.spawn(callback, value)
    end

    -- Dragging Logic with Dynamic Connections to avoid memory leaks
    local dragging = false
    local dragConnection, endConnection
    
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateFromPos(input.Position.X)
            
            -- Knob scale up
            Utils.Tween(Knob, 0.15, {Size = UDim2.new(0, 20, 0, 20)})

            dragConnection = UIS.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    UpdateFromPos(moveInput.Position.X)
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
                    Utils.Tween(Knob, 0.15, {Size = UDim2.new(0, 16, 0, 16)})
                end
            end)
        end
    end)

    -- Hover effect on track
    Track.MouseEnter:Connect(function()
        Utils.Tween(Track, 0.15, {BackgroundTransparency = 0.4})
    end)
    Track.MouseLeave:Connect(function()
        if not dragging then
            Utils.Tween(Track, 0.15, {BackgroundTransparency = 0.5})
        end
    end)

    table.insert(Tab.Elements, { Frame = Frame, Name = name })

    return {
        Set = function(v)
            value = math.clamp(v, min, max)
            UpdateVisuals(value)
            task.spawn(callback, value)
        end,
        Get = function() return value end
    }
end