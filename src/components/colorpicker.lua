-- src/components/colorpicker.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)
local UIS = game:GetService("UserInputService")

-- HSV to RGB conversion
local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    
    return Color3.new(r, g, b)
end

-- RGB to HSV conversion
local function RGBtoHSV(color)
    local r, g, b = color.R, color.G, color.B
    local maxVal = math.max(r, g, b)
    local minVal = math.min(r, g, b)
    local delta = maxVal - minVal
    
    local h, s, v = 0, 0, maxVal
    
    if maxVal ~= 0 then
        s = delta / maxVal
    end
    
    if delta ~= 0 then
        if maxVal == r then
            h = (g - b) / delta
        elseif maxVal == g then
            h = 2 + (b - r) / delta
        else
            h = 4 + (r - g) / delta
        end
        h = h / 6
        if h < 0 then h = h + 1 end
    end
    
    return h, s, v
end

return function(Tab, name, defaultColor, callback)
    defaultColor = defaultColor or Color3.fromRGB(100, 150, 255)
    callback = callback or function() end
    
    local h, s, v = RGBtoHSV(defaultColor)
    local isOpen = false

    -- Main Frame (Glass)
    local Frame = Instance.new("Frame", Tab.Frame)
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = Theme.Glass
    Frame.BackgroundTransparency = 0.75
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.ZIndex = 10
    Utils.Corner(Frame, 8)
    Utils.GlassBorder(Frame, 0.8)

    -- Header
    local Header = Instance.new("TextButton", Frame)
    Header.Size = UDim2.new(1, 0, 0, 38)
    Header.BackgroundColor3 = Theme.Glass
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.ZIndex = 11
    Utils.Corner(Header, 8)

    -- Label
    local Label = Instance.new("TextLabel", Header)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Theme.Text
    Label.TextSize = 13
    Label.Font = Theme.Font
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 12

    -- Color Preview Button
    local Preview = Instance.new("TextButton", Header)
    Preview.Size = UDim2.new(0, 30, 0, 24)
    Preview.Position = UDim2.new(1, -40, 0.5, -12)
    Preview.BackgroundColor3 = defaultColor
    Preview.Text = ""
    Preview.AutoButtonColor = false
    Preview.ZIndex = 12
    Utils.Corner(Preview, 6)
    Utils.GlassBorder(Preview, 0.8)

    -- Picker Container
    local Picker = Instance.new("Frame", Frame)
    Picker.Size = UDim2.new(1, 0, 0, 0)
    Picker.Position = UDim2.new(0, 0, 0, 38)
    Picker.BackgroundColor3 = Theme.GlassLight
    Picker.BackgroundTransparency = 0.85
    Picker.BorderSizePixel = 0
    Picker.ClipsDescendants = true
    Picker.ZIndex = 10
    Utils.Corner(Picker, 8)

    -- Saturation/Value Picker Area
    local SVArea = Instance.new("Frame", Picker)
    SVArea.Size = UDim2.new(1, -20, 0, 120)
    SVArea.Position = UDim2.new(0, 10, 0, 10)
    SVArea.BackgroundColor3 = HSVtoRGB(h, 1, 1)
    SVArea.BorderSizePixel = 0
    SVArea.ZIndex = 11
    Utils.Corner(SVArea, 6)

    -- Saturation Gradient (White to Transparent)
    local SatGrad = Instance.new("UIGradient", SVArea)
    SatGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    SatGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })

    -- Value Gradient (Black to Transparent)
    local ValGrad = Instance.new("UIGradient", SVArea)
    ValGrad.Rotation = 90
    ValGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    })
    ValGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })

    -- SV Cursor
    local SVCursor = Instance.new("Frame", SVArea)
    SVCursor.Size = UDim2.new(0, 8, 0, 8)
    SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SVCursor.BorderSizePixel = 0
    SVCursor.ZIndex = 12
    Utils.Corner(SVCursor, 4)
    local SVCursorStroke = Instance.new("UIStroke", SVCursor)
    SVCursorStroke.Color = Color3.fromRGB(0, 0, 0)
    SVCursorStroke.Thickness = 1

    -- Hue Slider
    local HueSlider = Instance.new("Frame", Picker)
    HueSlider.Size = UDim2.new(1, -20, 0, 12)
    HueSlider.Position = UDim2.new(0, 10, 0, 140)
    HueSlider.BorderSizePixel = 0
    HueSlider.ZIndex = 11
    Utils.Corner(HueSlider, 6)

    -- Hue Gradient (Rainbow)
    local HueGrad = Instance.new("UIGradient", HueSlider)
    HueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })

    -- Hue Cursor
    local HueCursor = Instance.new("Frame", HueSlider)
    HueCursor.Size = UDim2.new(0, 4, 1, 0)
    HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HueCursor.BorderSizePixel = 0
    HueCursor.ZIndex = 12
    Utils.Corner(HueCursor, 2)
    local HueCursorStroke = Instance.new("UIStroke", HueCursor)
    HueCursorStroke.Color = Color3.fromRGB(0, 0, 0)
    HueCursorStroke.Thickness = 1

    -- Update Function
    local function UpdateColor()
        local color = HSVtoRGB(h, s, v)
        Preview.BackgroundColor3 = color
        SVArea.BackgroundColor3 = HSVtoRGB(h, 1, 1)
        SVCursor.Position = UDim2.new(s, -4, 1 - v, -4)
        HueCursor.Position = UDim2.new(h, -2, 0, 0)
        task.spawn(callback, color)
    end

    -- SV Dragging
    local svDragging = false
    local svDragConn, svEndConn
    
    SVArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            svDragging = true
            
            local function updateSV(pos)
                local sizeX = SVArea.AbsoluteSize.X
                local sizeY = SVArea.AbsoluteSize.Y
                if sizeX <= 0 or sizeY <= 0 then return end
                
                local relX = math.clamp(pos.X - SVArea.AbsolutePosition.X, 0, sizeX)
                local relY = math.clamp(pos.Y - SVArea.AbsolutePosition.Y, 0, sizeY)
                s = relX / sizeX
                v = 1 - (relY / sizeY)
                UpdateColor()
            end
            
            updateSV(input.Position)
            
            svDragConn = UIS.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    updateSV(moveInput.Position)
                end
            end)
            
            svEndConn = UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    svDragging = false
                    if svDragConn then svDragConn:Disconnect() svDragConn = nil end
                    if svEndConn then svEndConn:Disconnect() svEndConn = nil end
                end
            end)
        end
    end)

    -- Hue Dragging
    local hueDragging = false
    local hueDragConn, hueEndConn
    
    HueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = true
            
            local function updateHue(pos)
                local sizeX = HueSlider.AbsoluteSize.X
                if sizeX <= 0 then return end
                
                local relX = math.clamp(pos.X - HueSlider.AbsolutePosition.X, 0, sizeX)
                h = relX / sizeX
                UpdateColor()
            end
            
            updateHue(input.Position)
            
            hueDragConn = UIS.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    updateHue(moveInput.Position)
                end
            end)
            
            hueEndConn = UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = false
                    if hueDragConn then hueDragConn:Disconnect() hueDragConn = nil end
                    if hueEndConn then hueEndConn:Disconnect() hueEndConn = nil end
                end
            end)
        end
    end)

    -- Toggle Picker
    Header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            Utils.Tween(Frame, 0.25, {Size = UDim2.new(1, 0, 0, 200)})
            Utils.Tween(Picker, 0.25, {Size = UDim2.new(1, 0, 0, 162)})
        else
            Utils.Tween(Picker, 0.25, {Size = UDim2.new(1, 0, 0, 0)})
            Utils.Tween(Frame, 0.25, {Size = UDim2.new(1, 0, 0, 38)})
        end
    end)

    -- Initialize position
    UpdateColor()

    table.insert(Tab.Elements, { Frame = Frame, Name = name })

    return {
        Set = function(color)
            h, s, v = RGBtoHSV(color)
            UpdateColor()
        end,
        Get = function() return HSVtoRGB(h, s, v) end
    }
end