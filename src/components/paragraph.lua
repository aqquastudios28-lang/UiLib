-- src/components/paragraph.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)

return function(Tab, title, body)
    -- Main Container Frame (Glass, AutomaticSize Y)
    local Frame = Instance.new("Frame", Tab.Frame)
    Frame.Size = UDim2.new(1, 0, 0, 0)
    Frame.BackgroundColor3 = Theme.Glass
    Frame.BackgroundTransparency = 0.8
    Frame.BorderSizePixel = 0
    Frame.AutomaticSize = Enum.AutomaticSize.Y
    Frame.ZIndex = 2
    Utils.Corner(Frame, 8)
    Utils.GlassBorder(Frame, 0.8)

    local Layout = Instance.new("UIListLayout", Frame)
    Layout.Padding = UDim.new(0, 4)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local Pad = Instance.new("UIPadding", Frame)
    Pad.PaddingLeft = UDim.new(0, 14)
    Pad.PaddingRight = UDim.new(0, 14)
    Pad.PaddingTop = UDim.new(0, 10)
    Pad.PaddingBottom = UDim.new(0, 10)

    -- Paragraph Title (Accent Color)
    local TitleLabel = Instance.new("TextLabel", Frame)
    TitleLabel.Size = UDim2.new(1, 0, 0, 18)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or ""
    TitleLabel.TextColor3 = Theme.Accent
    TitleLabel.TextSize = 13
    TitleLabel.Font = Theme.FontBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 3
    TitleLabel.Visible = (title ~= "")

    -- Paragraph Body (Text Wrapped, AutoSize)
    local BodyLabel = Instance.new("TextLabel", Frame)
    BodyLabel.Size = UDim2.new(1, 0, 0, 0)
    BodyLabel.BackgroundTransparency = 1
    BodyLabel.Text = body or ""
    BodyLabel.TextColor3 = Theme.Text
    BodyLabel.TextSize = 11
    BodyLabel.Font = Theme.Font
    BodyLabel.TextXAlignment = Enum.TextXAlignment.Left
    BodyLabel.TextYAlignment = Enum.TextYAlignment.Top
    BodyLabel.TextWrapped = true
    BodyLabel.AutomaticSize = Enum.AutomaticSize.Y
    BodyLabel.ZIndex = 3

    table.insert(Tab.Elements, { Frame = Frame, Name = (title or "") .. " " .. (body or "") })

    return {
        Set = function(newTitle, newBody)
            TitleLabel.Text = newTitle or ""
            TitleLabel.Visible = (newTitle ~= "")
            BodyLabel.Text = newBody or ""
        end,
        Frame = Frame
    }
end
