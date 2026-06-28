-- src/core/notification.lua
local Theme = require(script.Parent.theme)
local Utils = require(script.Parent.utils)

local NotificationManager = {}
local Container = nil

local function GetContainer(parentScreenGui)
    if Container then return Container end
    
    Container = Instance.new("Frame", parentScreenGui)
    Container.Name = "NotificationContainer"
    Container.Size = UDim2.new(0, 280, 1, -40)
    Container.Position = UDim2.new(1, -290, 0, 20)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 999999
    
    local Layout = Instance.new("UIListLayout", Container)
    Layout.Padding = UDim.new(0, 10)
    Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    return Container
end

function NotificationManager.Notify(parentScreenGui, config)
    config = config or {}
    local titleText = config.Title or "Notification"
    local descText = config.Content or "Success!"
    local duration = config.Duration or 5
    local iconStr = config.Image or "🔔" -- Text emoji or Asset ID
    
    local container = GetContainer(parentScreenGui)
    
    -- Main Toast Frame (Glass)
    local Toast = Instance.new("Frame", container)
    Toast.Size = UDim2.new(1, 0, 0, 68)
    Toast.BackgroundColor3 = Theme.Glass
    Toast.BackgroundTransparency = 0.75
    Toast.BorderSizePixel = 0
    Toast.Position = UDim2.new(1, 300, 0, 0) -- Start offscreen right
    Toast.ZIndex = 1000000
    Utils.Corner(Toast, 8)
    Utils.GlassBorder(Toast, 1)
    
    -- Slide-in shadow
    local shadow = Utils.CreateShadow(Toast, UDim2.new(1, 10, 1, 10), UDim2.new(0, -5, 0, -5), 0.5)
    shadow.ZIndex = Toast.ZIndex - 1
    
    -- Icon Label
    local Icon = Instance.new("TextLabel", Toast)
    Icon.Size = UDim2.new(0, 32, 0, 32)
    Icon.Position = UDim2.new(0, 12, 0.5, -16)
    Icon.BackgroundTransparency = 1
    Icon.Text = iconStr
    Icon.TextSize = 20
    Icon.ZIndex = Toast.ZIndex + 1
    
    -- If it's an asset id instead of an emoji
    if tostring(iconStr):find("rbxassetid") or tostring(iconStr):find("http") then
        Icon.Text = ""
        local IconImg = Instance.new("ImageLabel", Toast)
        IconImg.Size = UDim2.new(0, 24, 0, 24)
        IconImg.Position = UDim2.new(0, 16, 0.5, -12)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = iconStr
        IconImg.ZIndex = Toast.ZIndex + 1
    end
    
    -- Title Text
    local Title = Instance.new("TextLabel", Toast)
    Title.Size = UDim2.new(1, -60, 0, 18)
    Title.Position = UDim2.new(0, 50, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 13
    Title.Font = Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = Toast.ZIndex + 1
    
    -- Description Text
    local Desc = Instance.new("TextLabel", Toast)
    Desc.Size = UDim2.new(1, -60, 0, 28)
    Desc.Position = UDim2.new(0, 50, 0, 28)
    Desc.BackgroundTransparency = 1
    Desc.Text = descText
    Desc.TextColor3 = Theme.Text
    Desc.TextSize = 11
    Desc.Font = Theme.Font
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.TextYAlignment = Enum.TextYAlignment.Top
    Desc.TextWrapped = true
    Desc.ZIndex = Toast.ZIndex + 1
    
    -- Progress Bar Track
    local ProgressTrack = Instance.new("Frame", Toast)
    ProgressTrack.Size = UDim2.new(1, -4, 0, 2)
    ProgressTrack.Position = UDim2.new(0, 2, 1, -4)
    ProgressTrack.BackgroundColor3 = Theme.GlassLight
    ProgressTrack.BackgroundTransparency = 0.5
    ProgressTrack.ZIndex = Toast.ZIndex + 1
    Utils.Corner(ProgressTrack, 1)
    
    -- Progress Bar Fill
    local ProgressFill = Instance.new("Frame", ProgressTrack)
    ProgressFill.Size = UDim2.new(1, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Theme.Accent
    ProgressFill.ZIndex = Toast.ZIndex + 2
    Utils.Corner(ProgressFill, 1)
    
    -- Slide-in Tween
    Utils.Tween(Toast, 0.35, {Position = UDim2.new(0, 0, 0, 0)})
    
    -- Progress bar shrinking Tween
    Utils.Tween(ProgressFill, duration, {Size = UDim2.new(0, 0, 1, 0)})
    
    -- Auto-dismiss delay
    task.delay(duration, function()
        Utils.Tween(Toast, 0.35, {
            Position = UDim2.new(1, 300, 0, 0),
            BackgroundTransparency = 1
        })
        -- Fade out labels as well
        Utils.Tween(Title, 0.25, {TextTransparency = 1})
        Utils.Tween(Desc, 0.25, {TextTransparency = 1})
        Utils.Tween(Icon, 0.25, {TextTransparency = 1})
        
        task.delay(0.35, function()
            Toast:Destroy()
        end)
    end)
end

return NotificationManager
