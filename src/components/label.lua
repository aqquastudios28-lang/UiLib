-- src/components/label.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)

return function(Tab, text, alignment)
    alignment = alignment or Enum.TextXAlignment.Left
    
    -- Main Frame (Transparent)
    local Frame = Instance.new("Frame", Tab.Frame)
    Frame.Size = UDim2.new(1, 0, 0, 24)
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 2

    -- Text Label
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 12
    Label.Font = Theme.Font
    Label.TextXAlignment = alignment
    Label.ZIndex = 3

    table.insert(Tab.Elements, { Frame = Frame, Name = text })

    return {
        SetText = function(newText)
            Label.Text = newText
        end,
        GetText = function()
            return Label.Text
        end,
        SetColor = function(color)
            Label.TextColor3 = color
        end,
        Frame = Frame
    }
end
