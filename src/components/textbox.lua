-- src/components/textbox.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)
local Icons = require(script.Parent.Parent.core.icons)

return function(Tab, name, placeholder, default, icon, callback)
    -- Handle parameter overloading for backwards compatibility
    if type(icon) == "function" then
        callback = icon
        icon = nil
    end
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
            IconTxt.TextSize = 12
            IconTxt.Font = Theme.Font
            IconTxt.ZIndex = 3
        end
    end

    -- Label
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0, 80, 1, 0)
    Label.Position = UDim2.new(0, icon and 34 or 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Theme.SubText
    Label.TextSize = 12
    Label.Font = Theme.Font
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 3

    -- Input Box
    local Input = Instance.new("TextBox", Frame)
    Input.Size = UDim2.new(1, icon and -130 or -110, 0, 26)
    Input.Position = UDim2.new(0, icon and 115 or 95, 0.5, -13)
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
            Size = UDim2.new(1, icon and -125 or -105, 0, 28)
        })
        Utils.Tween(Frame, 0.2, {BackgroundTransparency = 0.7})
        if IconImg then Utils.Tween(IconImg, 0.2, {ImageColor3 = Theme.Accent}) end
        if IconTxt then Utils.Tween(IconTxt, 0.2, {TextColor3 = Theme.Accent}) end
    end)

    Input.FocusLost:Connect(function(enterPressed)
        Utils.Tween(Input, 0.2, {
            BackgroundTransparency = 0.7,
            Size = UDim2.new(1, icon and -130 or -110, 0, 26)
        })
        Utils.Tween(Frame, 0.2, {BackgroundTransparency = 0.75})
        if IconImg then Utils.Tween(IconImg, 0.2, {ImageColor3 = Theme.SubText}) end
        if IconTxt then Utils.Tween(IconTxt, 0.2, {TextColor3 = Theme.SubText}) end
        
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