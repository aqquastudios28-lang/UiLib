-- src/components/section.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)

return function(Tab, name)
    -- Section Header
    local Header = Instance.new("Frame", Tab.Frame)
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = Theme.Glass
    Header.BackgroundTransparency = 0.85
    Header.BorderSizePixel = 0
    Header.ZIndex = 2
    Utils.Corner(Header, 6)
    Utils.GlassBorder(Header, 0.6)

    -- Section Title
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 12
    Title.Font = Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3

    -- Section Content Container
    local Content = Instance.new("Frame", Tab.Frame)
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.BackgroundTransparency = 1
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.ZIndex = 2

    local Layout = Instance.new("UIListLayout", Content)
    Layout.Padding = UDim.new(0, 8)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
    end)

    table.insert(Tab.Elements, { Frame = Header, Name = name })

    return {
        Frame = Content,
        Elements = {}
    }
end