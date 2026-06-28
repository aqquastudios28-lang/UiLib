-- src/components/keybind.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)
local UIS = game:GetService("UserInputService")

return function(Tab, name, defaultKey, callback)
    local boundKey = defaultKey or Enum.KeyCode.RightShift
    callback = callback or function() end
    
    local isBinding = false
    
    -- Main Keybind Frame (Glass)
    local Frame = Instance.new("Frame", Tab.Frame)
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = Theme.Glass
    Frame.BackgroundTransparency = 0.75
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 2
    Utils.Corner(Frame, 8)
    Utils.GlassBorder(Frame, 0.8)

    -- Label
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -120, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Theme.Text
    Label.TextSize = 13
    Label.Font = Theme.Font
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 3

    -- Keybind Button
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 90, 0, 24)
    Btn.Position = UDim2.new(1, -100, 0.5, -12)
    Btn.BackgroundColor3 = Theme.GlassLight
    Btn.BackgroundTransparency = 0.7
    Btn.Text = boundKey and tostring(boundKey.Name or boundKey) or "None"
    Btn.TextColor3 = Theme.Accent
    Btn.TextSize = 12
    Btn.Font = Theme.FontBold
    Btn.AutoButtonColor = false
    Btn.ZIndex = 3
    Utils.Corner(Btn, 6)
    Utils.GlassBorder(Btn, 0.6)

    -- Format display text for mouse and keys
    local function GetKeyName(input)
        if not input then return "None" end
        if input == Enum.KeyCode.Unknown then return "None" end
        
        local nameStr = tostring(input.Name or input)
        -- Clean up Roblox names
        nameStr = nameStr:gsub("MouseButton", "MB")
        return nameStr
    end

    local function UpdateButton()
        Btn.Text = isBinding and "..." or GetKeyName(boundKey)
        Utils.Tween(Btn, 0.15, {
            TextColor3 = isBinding and Theme.Text or Theme.Accent,
            BackgroundColor3 = isBinding and Theme.Accent or Theme.GlassLight,
            BackgroundTransparency = isBinding and 0.4 or 0.7
        })
    end

    -- Global Bind Listener
    local inputConnection
    inputConnection = UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        -- Trigger bind callback
        if boundKey then
            if input.KeyCode == boundKey or input.UserInputType == boundKey then
                task.spawn(callback, boundKey)
            end
        end
    end)

    -- Bind Capture Logic
    Btn.MouseButton1Click:Connect(function()
        if isBinding then return end
        isBinding = true
        UpdateButton()
        
        local tempConnection
        tempConnection = UIS.InputBegan:Connect(function(input, processed)
            -- Don't capture text inputs
            if UIS:GetFocusedTextBox() then return end
            
            local key = nil
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                key = input.KeyCode
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or 
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                key = input.UserInputType
            end
            
            -- Cancel/Clear if escape or backspace
            if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
                boundKey = nil
                isBinding = false
                tempConnection:Disconnect()
                UpdateButton()
                return
            end
            
            if key then
                boundKey = key
                isBinding = false
                tempConnection:Disconnect()
                UpdateButton()
            end
        end)
    end)

    -- Hover effects
    Frame.MouseEnter:Connect(function()
        Utils.Tween(Frame, 0.15, {BackgroundTransparency = 0.65})
    end)
    Frame.MouseLeave:Connect(function()
        Utils.Tween(Frame, 0.15, {BackgroundTransparency = 0.75})
    end)

    table.insert(Tab.Elements, { Frame = Frame, Name = name })

    -- Clean up connections on destroy
    Frame.Destroying:Connect(function()
        if inputConnection then inputConnection:Disconnect() end
    end)

    return {
        Set = function(newKey)
            boundKey = newKey
            UpdateButton()
        end,
        Get = function() return boundKey end
    }
end
