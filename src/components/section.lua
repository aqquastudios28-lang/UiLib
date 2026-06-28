-- src/components/section.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)
local Icons = require(script.Parent.Parent.core.icons)

return function(Tab, name, icon)
    local isExpanded = true

    -- Section Header (Clickable Button for collapse/expand)
    local Header = Instance.new("TextButton", Tab.Frame)
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = Theme.Glass
    Header.BackgroundTransparency = 0.85
    Header.BorderSizePixel = 0
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.ZIndex = 2
    Utils.Corner(Header, 6)
    Utils.GlassBorder(Header, 0.6)
    Utils.HoverEffect(Header, Theme.GlassLight, Theme.Glass)

    -- Lucide Icon Prefix (Optional)
    local IconImg, IconTxt
    if icon then
        local resolved = Icons.Get(icon) or icon
        if tostring(resolved):find("rbxassetid") or tostring(resolved):find("http") then
            IconImg = Instance.new("ImageLabel", Header)
            IconImg.Size = UDim2.new(0, 14, 0, 14)
            IconImg.Position = UDim2.new(0, 10, 0.5, -7)
            IconImg.BackgroundTransparency = 1
            IconImg.Image = resolved
            IconImg.ImageColor3 = Theme.Accent
            IconImg.ZIndex = 3
        else
            IconTxt = Instance.new("TextLabel", Header)
            IconTxt.Size = UDim2.new(0, 14, 1, 0)
            IconTxt.Position = UDim2.new(0, 10, 0, 0)
            IconTxt.BackgroundTransparency = 1
            IconTxt.Text = resolved
            IconTxt.TextColor3 = Theme.Accent
            IconTxt.TextSize = 12
            IconTxt.Font = Theme.Font
            IconTxt.ZIndex = 3
        end
    end

    -- Section Title
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, icon and -60 or -40, 1, 0)
    Title.Position = UDim2.new(0, icon and 30 or 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 12
    Title.Font = Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3

    -- Collapse Arrow
    local Arrow = Instance.new("TextLabel", Header)
    Arrow.Size = UDim2.new(0, 24, 1, 0)
    Arrow.Position = UDim2.new(1, -26, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = Theme.Muted
    Arrow.TextSize = 9
    Arrow.Font = Theme.FontBold
    Arrow.ZIndex = 3

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

    -- Toggle expand/collapse action
    Header.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        Arrow.Text = isExpanded and "▼" or "►"
        Content.Visible = isExpanded
    end)

    table.insert(Tab.Elements, { Frame = Header, Name = name })

    return {
        Frame = Content,
        Header = Header,
        Arrow = Arrow,
        Title = Title,
        IconImg = IconImg,
        IconTxt = IconTxt,
        Elements = {}
    }
end