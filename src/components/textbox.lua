-- src/components/textbox.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)

return function(Tab, name, placeholder, default, callback)
    placeholder = placeholder or "Enter text..."
    default = default or ""
    callback = callback or function() end

    -- Main Frame (Glass)
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
    Label.Size = UDim2.new(0, 80, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Theme.SubText
    Label.TextSize = 12
    Label.Font = Theme.Font
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 3

    -- Input Box
    local Input = Instance.new("TextBox", Frame)
    Input.Size = UDim2.new(1, -110, 0, 26)
    Input.Position = UDim2.new(0, 95, 0.5, -13)
    Input.BackgroundColor3 = Theme.GlassLight
    Input.BackgroundTransparency = 0.7
    Input.Text = default
    Input.PlaceholderText = placeholder
    Input.PlaceholderColor3 = Theme.Muted
    Input.TextColor3 = Theme.Text
    Input.TextSize = 12
    Input.Font = Theme.Font
    Input.ClearTextOnFocus = false
    Input.ZIndex = 3
    Utils.Corner(Input, 6)

    -- Focus Animation
    Input.Focused:Connect(function()
        Utils.Tween(Input, 0.2, {
            BackgroundTransparency = 0.6,
            Size = UDim2.new(1, -105, 0, 28)
        })
        Utils.Tween(Frame, 0.2, {BackgroundTransparency = 0.7})
    end)

    Input.FocusLost:Connect(function(enterPressed)
        Utils.Tween(Input, 0.2, {
            BackgroundTransparency = 0.7,
            Size = UDim2.new(1, -110, 0, 26)
        })
        Utils.Tween(Frame, 0.2, {BackgroundTransparency = 0.75})
        
        if enterPressed then
            task.spawn(callback, Input.Text)
        end
    end)

    -- Live text change
    Input:GetPropertyChangedSignal("Text"):Connect(function()
        task.spawn(callback, Input.Text)
    end)

    table.insert(Tab.Elements, { Frame = Frame, Name = name })

    return {
        Set = function(text) Input.Text = text end,
        Get = function() return Input.Text end
    }
end