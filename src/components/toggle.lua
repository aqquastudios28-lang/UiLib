-- src/components/toggle.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)
local Icons = require(script.Parent.Parent.core.icons)

return function(Tab, name, default, icon, callback)
    -- Handle parameter overloading for backwards compatibility
    if type(icon) == "function" then
        callback = icon
        icon = nil
    end
    if type(default) == "function" then
        callback = default
        default = false
        icon = nil
    end
    
    local state = default or false
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
            IconImg.ImageColor3 = Theme.SubText
            IconImg.ZIndex = 3
        else
            IconTxt = Instance.new("TextLabel", Frame)
            IconTxt.Size = UDim2.new(0, 16, 1, 0)
            IconTxt.Position = UDim2.new(0, 12, 0, 0)
            IconTxt.BackgroundTransparency = 1
            IconTxt.Text = resolved
            IconTxt.TextColor3 = Theme.SubText
            IconTxt.TextSize = 13
            IconTxt.Font = Theme.Font
            IconTxt.ZIndex = 3
        end
    end

    -- Label
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, icon and -100 or -80, 1, 0)
    Label.Position = UDim2.new(0, icon and 36 or 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Theme.Text
    Label.TextSize = 13
    Label.Font = Theme.Font
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 3

    -- Toggle Button (Glass Track)
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 44, 0, 24)
    Btn.Position = UDim2.new(1, -54, 0.5, -12)
    Btn.BackgroundColor3 = state and Theme.Accent or Theme.GlassLight
    Btn.BackgroundTransparency = state and 0.3 or 0.6
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.ZIndex = 3
    Utils.Corner(Btn, 12)
    Utils.GlassBorder(Btn, 0.8)

    -- Toggle Circle (Glass Knob)
    local Circle = Instance.new("Frame", Btn)
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Circle.BackgroundColor3 = Theme.Text
    Circle.BackgroundTransparency = 0.1
    Circle.ZIndex = 4
    Utils.Corner(Circle, 9)

    -- Inner glow on circle
    local CircleGlow = Instance.new("UIGradient", Circle)
    CircleGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
    })
    CircleGlow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 0.6)
    })

    local function Update()
        Utils.Tween(Btn, 0.25, {
            BackgroundColor3 = state and Theme.Accent or Theme.GlassLight,
            BackgroundTransparency = state and 0.3 or 0.6
        })
        Utils.Tween(Circle, 0.25, {
            Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        })
        if IconImg then
            Utils.Tween(IconImg, 0.2, {ImageColor3 = state and Theme.Accent or Theme.SubText})
        end
        if IconTxt then
            Utils.Tween(IconTxt, 0.2, {TextColor3 = state and Theme.Accent or Theme.SubText})
        end
        task.spawn(callback, state)
    end

    -- Hover effect
    Frame.MouseEnter:Connect(function()
        Utils.Tween(Frame, 0.15, {BackgroundTransparency = 0.65})
    end)
    Frame.MouseLeave:Connect(function()
        Utils.Tween(Frame, 0.15, {BackgroundTransparency = 0.75})
    end)

    Btn.MouseButton1Click:Connect(function()
        state = not state
        Update()
    end)

    table.insert(Tab.Elements, { Frame = Frame, Name = name })

    return {
        Set = function(v) state = v Update() end,
        Get = function() return state end
    }
end