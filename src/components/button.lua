-- src/components/button.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)
local Icons = require(script.Parent.Parent.core.icons)

return function(Tab, name, icon, callback)
    -- Handle backwards compatibility for Tab:CreateButton(name, callback)
    if type(icon) == "function" then
        callback = icon
        icon = nil
    end
    callback = callback or function() end

    -- Main Button Frame (Glass)
    local Frame = Instance.new("TextButton", Tab.Frame)
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = Theme.Glass
    Frame.BackgroundTransparency = 0.75
    Frame.Text = ""
    Frame.AutoButtonColor = false
    Frame.ZIndex = 2
    Utils.Corner(Frame, 8)
    Utils.GlassBorder(Frame, 0.8)

    -- Lucide Icon Prefix (Optional)
    local IconImg, IconTxt
    if icon then
        local resolved = Icons.Get(icon) or icon
        if tostring(resolved):find("rbxassetid") or tostring(resolved):find("http") then
            IconImg = Instance.new("ImageLabel", Frame)
            IconImg.Size = UDim2.new(0, 16, 0, 16)
            IconImg.Position = UDim2.new(0, 12, 0.5, -8)
            IconImg.BackgroundTransparency = 1
            IconImg.Image = resolved
            IconImg.ImageColor3 = Theme.Text
            IconImg.ZIndex = 3
        else
            IconTxt = Instance.new("TextLabel", Frame)
            IconTxt.Size = UDim2.new(0, 16, 1, 0)
            IconTxt.Position = UDim2.new(0, 12, 0, 0)
            IconTxt.BackgroundTransparency = 1
            IconTxt.Text = resolved
            IconTxt.TextColor3 = Theme.Text
            IconTxt.TextSize = 13
            IconTxt.Font = Theme.Font
            IconTxt.ZIndex = 3
        end
    end

    -- Button Label
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, icon and -42 or -20, 1, 0)
    Label.Position = UDim2.new(0, icon and 34 or 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Theme.Text
    Label.TextSize = 13
    Label.Font = Theme.Font
    Label.ZIndex = 3
    Label.TextXAlignment = icon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center

    -- Accent glow layer (hidden by default)
    local Glow = Instance.new("Frame", Frame)
    Glow.Size = UDim2.new(1, 0, 1, 0)
    Glow.BackgroundColor3 = Theme.Accent
    Glow.BackgroundTransparency = 1
    Glow.ZIndex = 2
    Utils.Corner(Glow, 8)

    -- Hover Effect
    Frame.MouseEnter:Connect(function()
        Utils.Tween(Frame, 0.2, {BackgroundTransparency = 0.65})
        Utils.Tween(Glow, 0.2, {BackgroundTransparency = 0.85})
        Utils.Tween(Label, 0.2, {TextColor3 = Theme.Text})
        if IconImg then Utils.Tween(IconImg, 0.2, {ImageColor3 = Theme.Accent}) end
        if IconTxt then Utils.Tween(IconTxt, 0.2, {TextColor3 = Theme.Accent}) end
    end)

    Frame.MouseLeave:Connect(function()
        Utils.Tween(Frame, 0.2, {BackgroundTransparency = 0.75})
        Utils.Tween(Glow, 0.2, {BackgroundTransparency = 1})
        if IconImg then Utils.Tween(IconImg, 0.2, {ImageColor3 = Theme.Text}) end
        if IconTxt then Utils.Tween(IconTxt, 0.2, {TextColor3 = Theme.Text}) end
    end)

    -- Press Effect
    Frame.MouseButton1Down:Connect(function()
        Utils.Tween(Frame, 0.1, {Size = UDim2.new(1, -4, 0, 36)})
        Utils.Tween(Glow, 0.1, {BackgroundTransparency = 0.7})
    end)

    Frame.MouseButton1Up:Connect(function()
        Utils.Tween(Frame, 0.15, {Size = UDim2.new(1, 0, 0, 38)})
        Utils.Tween(Glow, 0.15, {BackgroundTransparency = 0.85})
    end)

    -- Click Handler
    Frame.MouseButton1Click:Connect(function()
        task.spawn(callback)
        
        -- Ripple effect
        local Ripple = Instance.new("Frame", Frame)
        Ripple.Size = UDim2.new(0, 0, 0, 38)
        Ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        Ripple.BackgroundColor3 = Theme.Accent
        Ripple.BackgroundTransparency = 0.7
        Ripple.ZIndex = 3
        Utils.Corner(Ripple, 8)
        
        Utils.Tween(Ripple, 0.4, {
            Size = UDim2.new(1.2, 0, 1.2, 0),
            BackgroundTransparency = 1
        })
        
        task.delay(0.4, function()
            Ripple:Destroy()
        end)
    end)

    table.insert(Tab.Elements, { Frame = Frame, Name = name })

    return {
        SetText = function(text) Label.Text = text end,
        Frame = Frame
    }
end