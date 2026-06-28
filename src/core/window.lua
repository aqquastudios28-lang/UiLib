-- src/core/window.lua
local Theme = require(script.Parent.theme)
local Utils = require(script.Parent.utils)
local Notification = require(script.Parent.notification)
local Icons = require(script.Parent.icons)
local UIS = game:GetService("UserInputService")

local WindowModule = {}

function WindowModule.new(config)
    local Window = { 
        Tabs = {}, 
        ActiveTab = nil,
        ActiveView = nil, -- Tracks either the active tab or active sub-tab for search filter
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift,
        Visible = true
    }
    config = config or {}

    -- GUI Setup
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "QwenUI_" .. math.random(10000, 99999)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Set ScreenGui Parent safely to avoid anti-cheat SEH crashes on broken executors
    local targetParent = config.Parent
    
    if not targetParent then
        print("[QwenUI] No config.Parent provided, searching for PlayerGui...")
        targetParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 5)
        if not targetParent then
            warn("[QwenUI] PlayerGui not found within 5 seconds! Defaulting to CoreGui to avoid silent freeze.")
            pcall(function() targetParent = game:GetService("CoreGui") end)
        end
    end
    print("[QwenUI] ScreenGui Parent set to:", tostring(targetParent))
    
    ScreenGui.Parent = targetParent

    -- Shadow Layer
    local Shadow = Instance.new("Frame", ScreenGui)
    Shadow.Size = config.Size or UDim2.new(0, 620, 0, 460)
    Shadow.Position = UDim2.new(0.5, -310, 0.5, -230)
    Shadow.BackgroundTransparency = 1
    
    local shadowObj = Utils.CreateShadow(Shadow, UDim2.new(1, 20, 1, 20), UDim2.new(0, -10, 0, -10), Theme.ShadowTransparency)

    -- Main Frame (Obsidian Dark Glass)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = config.Size or UDim2.new(0, 620, 0, 460)
    Main.Position = UDim2.new(0.5, -310, 0.5, -230)
    Main.BackgroundColor3 = Theme.Background
    Main.BackgroundTransparency = Theme.BackgroundTransparency
    Main.BorderSizePixel = 0
    Utils.Corner(Main, 12)
    local borderStroke = Utils.GlassBorder(Main, 1.5)
    Utils.MakeDraggable(Main, Main)

    -- Liquid Neon Background Blobs
    local Blob1 = Utils.CreateGlowBlob(Main, Theme.Blob1Color, UDim2.new(0, 260, 0, 260), UDim2.new(-0.2, 0, -0.2, 0))
    local Blob2 = Utils.CreateGlowBlob(Main, Theme.Blob2Color, UDim2.new(0, 300, 0, 300), UDim2.new(0.6, 0, 0.5, 0))
    
    -- Animate Neon Blobs (Liquid Flow)
    task.spawn(function()
        local startTime = os.clock()
        while task.wait(0.04) do
            if not Main or not Main.Parent then break end
            local t = (os.clock() - startTime) * Theme.BlobSpeed
            local x1 = -0.15 + 0.12 * math.sin(t * 0.4)
            local y1 = -0.15 + 0.12 * math.cos(t * 0.3)
            local x2 = 0.55 + 0.12 * math.cos(t * 0.25)
            local y2 = 0.45 + 0.12 * math.sin(t * 0.35)
            
            Blob1.Position = UDim2.new(x1, 0, y1, 0)
            Blob1.ImageColor3 = Theme.Blob1Color
            Blob1.ImageTransparency = Theme.BlobTransparency
            
            Blob2.Position = UDim2.new(x2, 0, y2, 0)
            Blob2.ImageColor3 = Theme.Blob2Color
            Blob2.ImageTransparency = Theme.BlobTransparency
        end
    end)

    -- Glass overlay for frosted effect
    local GlassOverlay = Instance.new("Frame", Main)
    GlassOverlay.Size = UDim2.new(1, 0, 1, 0)
    GlassOverlay.BackgroundColor3 = Theme.Glass
    GlassOverlay.BackgroundTransparency = Theme.GlassTransparency
    GlassOverlay.ZIndex = 1
    Utils.Corner(GlassOverlay, 12)

    -- Title Bar
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 42)
    TitleBar.BackgroundColor3 = Theme.GlassLight
    TitleBar.BackgroundTransparency = 0.65
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 3
    Utils.Corner(TitleBar, 12)
    
    -- Hide bottom rounded corners of title bar
    local TitleBarBottomCut = Instance.new("Frame", TitleBar)
    TitleBarBottomCut.Size = UDim2.new(1, 0, 0, 6)
    TitleBarBottomCut.Position = UDim2.new(0, 0, 1, -6)
    TitleBarBottomCut.BackgroundColor3 = Theme.GlassLight
    TitleBarBottomCut.BackgroundTransparency = 0.65
    TitleBarBottomCut.BorderSizePixel = 0
    TitleBarBottomCut.ZIndex = 3

    -- Title Text
    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(1, -220, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Name or "QwenUILib"
    Title.TextColor3 = Theme.Text
    Title.TextSize = 15
    Title.Font = Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 4

    -- Search Box (Glass Effect)
    local SearchContainer = Instance.new("Frame", TitleBar)
    SearchContainer.Size = UDim2.new(0, 180, 0, 28)
    SearchContainer.Position = UDim2.new(1, -260, 0.5, -14)
    SearchContainer.BackgroundColor3 = Theme.Glass
    SearchContainer.BackgroundTransparency = 0.75
    SearchContainer.ZIndex = 4
    Utils.Corner(SearchContainer, 6)
    Utils.GlassBorder(SearchContainer, 0.8)

    -- Close & Minimize Action Buttons
    local CloseBtn = Instance.new("TextButton", TitleBar)
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -34, 0.5, -12)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Theme.SubText
    CloseBtn.TextSize = 12
    CloseBtn.Font = Theme.FontBold
    CloseBtn.ZIndex = 5
    
    CloseBtn.MouseEnter:Connect(function()
        Utils.Tween(CloseBtn, 0.15, {TextColor3 = Color3.fromRGB(255, 80, 80)})
    end)
    CloseBtn.MouseLeave:Connect(function()
        Utils.Tween(CloseBtn, 0.15, {TextColor3 = Theme.SubText})
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local MinimizeBtn = Instance.new("TextButton", TitleBar)
    MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    MinimizeBtn.Position = UDim2.new(1, -62, 0.5, -12)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Theme.SubText
    MinimizeBtn.TextSize = 10
    MinimizeBtn.Font = Theme.FontBold
    MinimizeBtn.ZIndex = 5

    local minimized = false
    local originalSize = config.Size or UDim2.new(0, 620, 0, 460)

    MinimizeBtn.MouseEnter:Connect(function()
        Utils.Tween(MinimizeBtn, 0.15, {TextColor3 = Theme.Accent})
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        Utils.Tween(MinimizeBtn, 0.15, {TextColor3 = Theme.SubText})
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MinimizeBtn.Text = minimized and "⬜" or "—"
        
        if minimized then
            Utils.Tween(Main, 0.25, {Size = UDim2.new(0, originalSize.X.Offset, 0, 42)})
            Utils.Tween(Shadow, 0.25, {Size = UDim2.new(0, originalSize.X.Offset, 0, 42)})
            Sidebar.Visible = false
            Content.Visible = false
            Blob1.Visible = false
            Blob2.Visible = false
        else
            Utils.Tween(Main, 0.25, {Size = originalSize})
            Utils.Tween(Shadow, 0.25, {Size = originalSize})
            task.delay(0.25, function()
                if not minimized then
                    Sidebar.Visible = true
                    Content.Visible = true
                    Blob1.Visible = true
                    Blob2.Visible = true
                end
            end)
        end
    end)

    local SearchIcon = Instance.new("TextLabel", SearchContainer)
    SearchIcon.Size = UDim2.new(0, 24, 1, 0)
    SearchIcon.Position = UDim2.new(0, 8, 0, 0)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Text = "🔍"
    SearchIcon.TextSize = 12
    SearchIcon.TextColor3 = Theme.SubText
    SearchIcon.ZIndex = 5

    local SearchBox = Instance.new("TextBox", SearchContainer)
    SearchBox.Size = UDim2.new(1, -38, 1, 0)
    SearchBox.Position = UDim2.new(0, 32, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search elements..."
    SearchBox.PlaceholderColor3 = Theme.Muted
    SearchBox.TextColor3 = Theme.Text
    SearchBox.TextSize = 12
    SearchBox.Font = Theme.Font
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 5

    -- Sidebar (Scrollable Tab Container)
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Size = UDim2.new(0, 150, 1, -42)
    Sidebar.Position = UDim2.new(0, 0, 0, 42)
    Sidebar.BackgroundTransparency = 0.9
    Sidebar.BackgroundColor3 = Theme.Glass
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.ScrollBarImageColor3 = Theme.Accent
    Sidebar.ScrollBarImageTransparency = 0.7
    Sidebar.ZIndex = 2

    local TabLayout = Instance.new("UIListLayout", Sidebar)
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local TabPad = Instance.new("UIPadding", Sidebar)
    TabPad.PaddingTop = UDim.new(0, 12)
    TabPad.PaddingLeft = UDim.new(0, 10)
    TabPad.PaddingRight = UDim.new(0, 10)

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
    end)

    -- Content Area
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, -165, 1, -52)
    Content.Position = UDim2.new(0, 160, 0, 47)
    Content.BackgroundTransparency = 1
    Content.ZIndex = 2

    -- Global Keybind to Hide/Show UI
    local toggleConnection
    toggleConnection = UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Window.ToggleKey then
            Window.Visible = not Window.Visible
            Shadow.Visible = Window.Visible
            Main.Visible = Window.Visible
        end
    end)

    -- Central Reactive Theme Changed Connection
    local themeConnection
    themeConnection = Theme.Changed:Connect(function(oldTheme)
        if not oldTheme then return end
        
        -- Recursively update all descendants to match the new theme
        local function areColorsEqual(c1, c2)
            return math.abs(c1.R - c2.R) < 0.005 and math.abs(c1.G - c2.G) < 0.005 and math.abs(c1.B - c2.B) < 0.005
        end

        local function recurse(obj)
            -- Handle TextColor3 & Font
            if obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("TextButton") then
                if obj.Text ~= "" or obj:IsA("TextBox") then
                    if areColorsEqual(obj.TextColor3, oldTheme.Text) then
                        obj.TextColor3 = Theme.Text
                    elseif areColorsEqual(obj.TextColor3, oldTheme.SubText) then
                        obj.TextColor3 = Theme.SubText
                    elseif areColorsEqual(obj.TextColor3, oldTheme.Muted) then
                        obj.TextColor3 = Theme.Muted
                    elseif areColorsEqual(obj.TextColor3, oldTheme.Accent) then
                        obj.TextColor3 = Theme.Accent
                    end
                    
                    if obj.Font == oldTheme.Font then
                        obj.Font = Theme.Font
                    elseif obj.Font == oldTheme.FontBold then
                        obj.Font = Theme.FontBold
                    elseif obj.Font == oldTheme.FontLight then
                        obj.Font = Theme.FontLight
                    end
                end
            end

            -- Handle ImageLabel ImageColor3
            if obj:IsA("ImageLabel") then
                if obj.Name ~= "Blob1" and obj.Name ~= "Blob2" then
                    if areColorsEqual(obj.ImageColor3, oldTheme.Accent) then
                        obj.ImageColor3 = Theme.Accent
                    elseif areColorsEqual(obj.ImageColor3, oldTheme.Text) then
                        obj.ImageColor3 = Theme.Text
                    elseif areColorsEqual(obj.ImageColor3, oldTheme.SubText) then
                        obj.ImageColor3 = Theme.SubText
                    end
                end
            end
            
            -- Handle BackgroundColor3 & Transparency
            if obj:IsA("Frame") or obj:IsA("ScrollingFrame") or obj:IsA("TextButton") then
                if obj ~= ScreenGui and obj.Name ~= "NotificationContainer" and obj.Name ~= "Shadow" and obj.Name ~= "Blob1" and obj.Name ~= "Blob2" then
                    if areColorsEqual(obj.BackgroundColor3, oldTheme.Glass) then
                        obj.BackgroundColor3 = Theme.Glass
                        if obj.BackgroundTransparency == oldTheme.GlassTransparency then
                            obj.BackgroundTransparency = Theme.GlassTransparency
                        end
                    elseif areColorsEqual(obj.BackgroundColor3, oldTheme.GlassLight) then
                        obj.BackgroundColor3 = Theme.GlassLight
                    elseif areColorsEqual(obj.BackgroundColor3, oldTheme.Background) then
                        obj.BackgroundColor3 = Theme.Background
                        if obj.BackgroundTransparency == oldTheme.BackgroundTransparency then
                            obj.BackgroundTransparency = Theme.BackgroundTransparency
                        end
                    elseif areColorsEqual(obj.BackgroundColor3, oldTheme.Accent) then
                        obj.BackgroundColor3 = Theme.Accent
                    end
                end
            end

            -- Handle UIStroke
            if obj:IsA("UIStroke") then
                if areColorsEqual(obj.Color, oldTheme.GlassBorder) then
                    obj.Color = Theme.GlassBorder
                end
                local grad = obj:FindFirstChildWhichIsA("UIGradient")
                if grad then
                    grad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(0.4, Theme.GlassBorder),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
                    })
                end
            end

            -- Handle UIGradient sequences
            if obj:IsA("UIGradient") and obj.Parent and obj.Parent:IsA("Frame") then
                local parent = obj.Parent
                if areColorsEqual(parent.BackgroundColor3, Theme.Accent) then
                    obj.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Theme.Accent),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 200, 255):lerp(Theme.Accent, 0.5))
                    })
                end
            end

            for _, child in ipairs(obj:GetChildren()) do
                recurse(child)
            end
        end

        recurse(ScreenGui)

        -- Extra manual tuning for specific layout nodes
        if shadowObj then
            shadowObj.ImageColor3 = Theme.ShadowColor
            shadowObj.ImageTransparency = Theme.ShadowTransparency
        end
        Main.BackgroundColor3 = Theme.Background
        Main.BackgroundTransparency = Theme.BackgroundTransparency
        GlassOverlay.BackgroundColor3 = Theme.Glass
        GlassOverlay.BackgroundTransparency = Theme.GlassTransparency
        TitleBar.BackgroundColor3 = Theme.GlassLight
        TitleBarBottomCut.BackgroundColor3 = Theme.GlassLight
        Title.TextColor3 = Theme.Text
        Title.Font = Theme.FontBold
        SearchIcon.TextColor3 = Theme.SubText
        SearchBox.PlaceholderColor3 = Theme.Muted
        SearchBox.TextColor3 = Theme.Text
        SearchBox.Font = Theme.Font
        Sidebar.BackgroundColor3 = Theme.Glass
        Sidebar.ScrollBarImageColor3 = Theme.Accent
        CloseBtn.TextColor3 = Theme.SubText
        MinimizeBtn.TextColor3 = Theme.SubText

        -- Update Sidebar categories/tab groups labels
        for _, child in ipairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") and child:FindFirstChildWhichIsA("TextLabel") then
                local label = child:FindFirstChildWhichIsA("TextLabel")
                if label.Text:upper() == label.Text then
                    label.TextColor3 = Theme.Accent
                    label.Font = Theme.FontBold
                    local arrow = child:FindFirstChild("Arrow") or child:FindFirstChildWhichIsA("TextLabel")
                    if arrow and arrow ~= label then
                        arrow.TextColor3 = Theme.Muted
                        arrow.Font = Theme.FontBold
                    end
                end
            end
        end

        -- Update tab indicators and active state
        for _, t in ipairs(Window.Tabs) do
            if t == Window.ActiveTab then
                t.Button.BackgroundColor3 = Theme.Accent
                t.Button.BackgroundTransparency = 0.35
                t.Label.TextColor3 = Theme.Text
                if t.IconImg then t.IconImg.ImageColor3 = Theme.Accent end
                if t.IconTxt then t.IconTxt.TextColor3 = Theme.Accent end
                if t.Indicator then
                    t.Indicator.BackgroundColor3 = Theme.Accent
                    t.Indicator.BackgroundTransparency = 0
                    t.Indicator.Size = UDim2.new(0, 4, 1, -8)
                end
            else
                t.Button.BackgroundColor3 = Theme.Glass
                t.Button.BackgroundTransparency = 0.75
                t.Label.TextColor3 = Theme.SubText
                if t.IconImg then t.IconImg.ImageColor3 = Theme.SubText end
                if t.IconTxt then t.IconTxt.TextColor3 = Theme.SubText end
                if t.Indicator then
                    t.Indicator.BackgroundColor3 = Theme.Accent
                    t.Indicator.BackgroundTransparency = 1
                    t.Indicator.Size = UDim2.new(0, 0, 1, -8)
                end
            end

            if t.SubTabContainer then
                t.SubTabContainer.BackgroundColor3 = Theme.Glass
                for _, s in ipairs(t.SubTabs) do
                    if s == t.ActiveSubTab then
                        s.Button.BackgroundColor3 = Theme.Accent
                        s.Button.BackgroundTransparency = 0.4
                        s.Button.TextColor3 = Theme.Text
                        if s.Indicator then
                            s.Indicator.BackgroundColor3 = Theme.Accent
                            s.Indicator.BackgroundTransparency = 0
                            s.Indicator.Size = UDim2.new(1, -12, 0, 3)
                        end
                    else
                        s.Button.BackgroundColor3 = Theme.Glass
                        s.Button.BackgroundTransparency = 0.8
                        s.Button.TextColor3 = Theme.SubText
                        if s.Indicator then
                            s.Indicator.BackgroundColor3 = Theme.Accent
                            s.Indicator.BackgroundTransparency = 1
                            s.Indicator.Size = UDim2.new(1, -12, 0, 0)
                        end
                    end
                end
            end
        end
    end)

    ScreenGui.Destroying:Connect(function()
        if toggleConnection then
            toggleConnection:Disconnect()
            toggleConnection = nil
        end
        if themeConnection then
            themeConnection:Disconnect()
            themeConnection = nil
        end
    end)

    -- Search Filter Logic
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        if Window.ActiveView then
            for _, element in ipairs(Window.ActiveView.Elements) do
                if element.Frame then
                    local match = element.Name:lower():find(query, 1, true)
                    element.Frame.Visible = (query == "" or match ~= nil)
                end
            end
        end
    end)

    -- Tab Manager - Group Creation (Categories)
    function Window:CreateTabGroup(name)
        local Group = { Tabs = {}, Expanded = true }
        
        -- Group Header Button (clickable to collapse/expand)
        local GroupHeader = Instance.new("TextButton", Sidebar)
        GroupHeader.Size = UDim2.new(1, 0, 0, 24)
        GroupHeader.BackgroundTransparency = 1
        GroupHeader.Text = ""
        GroupHeader.ZIndex = 3
        
        local GroupLabel = Instance.new("TextLabel", GroupHeader)
        GroupLabel.Size = UDim2.new(1, -20, 1, 0)
        GroupLabel.Position = UDim2.new(0, 4, 0, 0)
        GroupLabel.BackgroundTransparency = 1
        GroupLabel.Text = name:upper()
        GroupLabel.TextColor3 = Theme.Accent
        GroupLabel.TextSize = 10
        GroupLabel.Font = Theme.FontBold
        GroupLabel.TextXAlignment = Enum.TextXAlignment.Left
        GroupLabel.ZIndex = 4
        
        local Arrow = Instance.new("TextLabel", GroupHeader)
        Arrow.Name = "Arrow"
        Arrow.Size = UDim2.new(0, 20, 1, 0)
        Arrow.Position = UDim2.new(1, -20, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"
        Arrow.TextColor3 = Theme.Muted
        Arrow.TextSize = 10
        Arrow.Font = Theme.FontBold
        Arrow.ZIndex = 4
        
        GroupHeader.MouseButton1Click:Connect(function()
            Group.Expanded = not Group.Expanded
            Arrow.Text = Group.Expanded and "▼" or "►"
            for _, tabBtn in ipairs(Group.Tabs) do
                tabBtn.Visible = Group.Expanded
            end
        end)
        
        function Group:CreateTab(tabName, tabIcon)
            local Tab = Window:CreateTab(tabName, tabIcon, GroupHeader)
            table.insert(Group.Tabs, Tab.Button)
            Tab.Button.Visible = Group.Expanded
            return Tab
        end
        
        return Group
    end

    -- Tab Creation
    function Window:CreateTab(name, icon, groupParent)
        local Tab = { 
            Elements = {}, 
            SubTabs = {}, 
            ActiveSubTab = nil,
            IsTab = true
        }
        
        -- Tab Button on Sidebar
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundColor3 = Theme.Glass
        TabBtn.BackgroundTransparency = 0.75
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.ZIndex = 3
        Utils.Corner(TabBtn, 6)
        Utils.GlassBorder(TabBtn, 0.8)

        -- Micro-indicator bar (sliding glass style expansion)
        local Indicator = Instance.new("Frame", TabBtn)
        Indicator.Size = UDim2.new(0, 0, 1, -8)
        Indicator.Position = UDim2.new(0, 2, 0.5, -4)
        Indicator.AnchorPoint = Vector2.new(0, 0.5)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.BackgroundTransparency = 1
        Indicator.ZIndex = 5
        Utils.Corner(Indicator, 2)
        Tab.Indicator = Indicator

        local TabLabel = Instance.new("TextLabel", TabBtn)
        TabLabel.Size = UDim2.new(1, icon and -42 or -24, 1, 0)
        TabLabel.Position = UDim2.new(0, icon and 32 or 12, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = name
        TabLabel.TextColor3 = Theme.SubText
        TabLabel.TextSize = 12
        TabLabel.Font = Theme.Font
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.ZIndex = 4

        local TabIconImg, TabIconTxt
        if icon then
            local resolved = Icons.Get(icon) or icon
            if tostring(resolved):find("rbxassetid") or tostring(resolved):find("http") then
                TabIconImg = Instance.new("ImageLabel", TabBtn)
                TabIconImg.Size = UDim2.new(0, 16, 0, 16)
                TabIconImg.Position = UDim2.new(0, 10, 0.5, -8)
                TabIconImg.BackgroundTransparency = 1
                TabIconImg.Image = resolved
                TabIconImg.ImageColor3 = Theme.SubText
                TabIconImg.ZIndex = 4
            else
                TabIconTxt = Instance.new("TextLabel", TabBtn)
                TabIconTxt.Size = UDim2.new(0, 16, 1, 0)
                TabIconTxt.Position = UDim2.new(0, 10, 0, 0)
                TabIconTxt.BackgroundTransparency = 1
                TabIconTxt.Text = resolved
                TabIconTxt.TextColor3 = Theme.SubText
                TabIconTxt.TextSize = 12
                TabIconTxt.Font = Theme.Font
                TabIconTxt.ZIndex = 4
            end
        end
        
        Tab.Label = TabLabel
        Tab.IconImg = TabIconImg
        Tab.IconTxt = TabIconTxt

        if groupParent then
            TabBtn.LayoutOrder = groupParent.LayoutOrder
        end

        -- Main Tab Content Scrolling Frame
        local TabFrame = Instance.new("ScrollingFrame", Content)
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.ZIndex = 2
        Utils.StyleScroll(TabFrame)
        
        local Layout = Instance.new("UIListLayout", TabFrame)
        Layout.Padding = UDim.new(0, 10)
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not Tab.SubTabContainer then -- Only change CanvasSize if not using Sub-tabs
                TabFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
            end
        end)
        
        local Pad = Instance.new("UIPadding", TabFrame)
        Pad.PaddingTop = UDim.new(0, 10)
        Pad.PaddingLeft = UDim.new(0, 10)
        Pad.PaddingRight = UDim.new(0, 10)

        -- Sub-Tabs Manager inside Tab
        function Tab:CreateSubTab(subName)
            -- Initialize Subtab bar if first subtab
            if not Tab.SubTabContainer then
                -- Convert main TabFrame to a container instead of a scrolling frame
                TabFrame.ScrollingEnabled = false
                TabFrame.ScrollBarThickness = 0
                TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                Layout:Destroy()
                Pad:Destroy()
                
                -- Create Top SubTab Selector Bar
                local SubTabContainer = Instance.new("Frame", TabFrame)
                SubTabContainer.Size = UDim2.new(1, 0, 0, 32)
                SubTabContainer.BackgroundColor3 = Theme.Glass
                SubTabContainer.BackgroundTransparency = 0.8
                SubTabContainer.BorderSizePixel = 0
                SubTabContainer.ZIndex = 3
                Utils.Corner(SubTabContainer, 6)
                Utils.GlassBorder(SubTabContainer, 0.6)
                
                local SubTabLayout = Instance.new("UIListLayout", SubTabContainer)
                SubTabLayout.FillDirection = Enum.FillDirection.Horizontal
                SubTabLayout.Padding = UDim.new(0, 6)
                SubTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                local SubTabPad = Instance.new("UIPadding", SubTabContainer)
                SubTabPad.PaddingLeft = UDim.new(0, 6)
                SubTabPad.PaddingRight = UDim.new(0, 6)
                SubTabPad.PaddingTop = UDim.new(0, 4)
                SubTabPad.PaddingBottom = UDim.new(0, 4)
                
                -- Content container frame for SubTab views
                local SubViews = Instance.new("Frame", TabFrame)
                SubViews.Size = UDim2.new(1, 0, 1, -38)
                SubViews.Position = UDim2.new(0, 0, 0, 38)
                SubViews.BackgroundTransparency = 1
                SubViews.ZIndex = 2
                
                Tab.SubTabContainer = SubTabContainer
                Tab.SubViews = SubViews
            end
            
            local SubTab = { Elements = {}, IsSubTab = true }
            
            -- Subtab selector button
            local SubBtn = Instance.new("TextButton", Tab.SubTabContainer)
            SubBtn.Size = UDim2.new(0, 100, 1, 0)
            SubBtn.BackgroundColor3 = Theme.Glass
            SubBtn.BackgroundTransparency = 0.8
            SubBtn.Text = subName
            SubBtn.TextColor3 = Theme.SubText
            SubBtn.TextSize = 11
            SubBtn.Font = Theme.Font
            SubBtn.AutoButtonColor = false
            SubBtn.ZIndex = 4
            Utils.Corner(SubBtn, 4)
            Utils.GlassBorder(SubBtn, 0.6)

            -- Subtab active bar indicator
            local SubIndicator = Instance.new("Frame", SubBtn)
            SubIndicator.Size = UDim2.new(1, -12, 0, 0)
            SubIndicator.Position = UDim2.new(0.5, 0, 1, -2)
            SubIndicator.AnchorPoint = Vector2.new(0.5, 1)
            SubIndicator.BackgroundColor3 = Theme.Accent
            SubIndicator.BackgroundTransparency = 1
            SubIndicator.ZIndex = 5
            Utils.Corner(SubIndicator, 1)
            SubTab.Indicator = SubIndicator
            
            -- Subtab View scrolling frame
            local SubFrame = Instance.new("ScrollingFrame", Tab.SubViews)
            SubFrame.Size = UDim2.new(1, 0, 1, 0)
            SubFrame.BackgroundTransparency = 1
            SubFrame.Visible = false
            SubFrame.ZIndex = 3
            Utils.StyleScroll(SubFrame)
            
            local SubLayout = Instance.new("UIListLayout", SubFrame)
            SubLayout.Padding = UDim.new(0, 8)
            SubLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SubFrame.CanvasSize = UDim2.new(0, 0, 0, SubLayout.AbsoluteContentSize.Y + 20)
            end)
            
            local SubPad = Instance.new("UIPadding", SubFrame)
            SubPad.PaddingTop = UDim.new(0, 8)
            SubPad.PaddingLeft = UDim.new(0, 8)
            SubPad.PaddingRight = UDim.new(0, 8)
            
            -- SubTab Selection Handler
            SubBtn.MouseButton1Click:Connect(function()
                for _, s in ipairs(Tab.SubTabs) do
                    s.Frame.Visible = false
                    Utils.Tween(s.Button, 0.2, {
                        BackgroundColor3 = Theme.Glass,
                        BackgroundTransparency = 0.8,
                        TextColor3 = Theme.SubText
                    })
                    if s.Indicator then
                        Utils.Tween(s.Indicator, 0.2, {
                            Size = UDim2.new(1, -12, 0, 0),
                            BackgroundTransparency = 1
                        })
                    end
                end
                SubFrame.Visible = true
                Utils.Tween(SubBtn, 0.2, {
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.4,
                    TextColor3 = Theme.Text
                })
                if SubIndicator then
                    Utils.Tween(SubIndicator, 0.2, {
                        Size = UDim2.new(1, -12, 0, 3),
                        BackgroundTransparency = 0
                    })
                end
                Tab.ActiveSubTab = SubTab
                Window.ActiveView = SubTab
                
                -- Reapply Search
                local q = SearchBox.Text:lower()
                for _, el in ipairs(SubTab.Elements) do
                    if el.Frame then
                        el.Frame.Visible = (q == "" or el.Name:lower():find(q, 1, true) ~= nil)
                    end
                end
            end)
            
            SubTab.Frame = SubFrame
            SubTab.Button = SubBtn
            table.insert(Tab.SubTabs, SubTab)
            
            -- Auto-select first subtab
            if #Tab.SubTabs == 1 then SubBtn.MouseButton1Click:Fire() end
            
            return SubTab
        end

        -- Tab Selection Click Handler
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Frame.Visible = false
                Utils.Tween(t.Button, 0.2, {
                    BackgroundColor3 = Theme.Glass,
                    BackgroundTransparency = 0.75
                })
                Utils.Tween(t.Label, 0.2, {TextColor3 = Theme.SubText})
                if t.IconImg then
                    Utils.Tween(t.IconImg, 0.2, {ImageColor3 = Theme.SubText})
                end
                if t.IconTxt then
                    Utils.Tween(t.IconTxt, 0.2, {TextColor3 = Theme.SubText})
                end
                if t.Indicator then
                    Utils.Tween(t.Indicator, 0.2, {
                        Size = UDim2.new(0, 0, 1, -8),
                        BackgroundTransparency = 1
                    })
                end
            end
            TabFrame.Visible = true
            Utils.Tween(TabBtn, 0.2, {
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.35
            })
            Utils.Tween(Tab.Label, 0.2, {TextColor3 = Theme.Text})
            if Tab.IconImg then
                Utils.Tween(Tab.IconImg, 0.2, {ImageColor3 = Theme.Accent})
            end
            if Tab.IconTxt then
                Utils.Tween(Tab.IconTxt, 0.2, {TextColor3 = Theme.Accent})
            end
            if Tab.Indicator then
                Utils.Tween(Tab.Indicator, 0.2, {
                    Size = UDim2.new(0, 4, 1, -8),
                    BackgroundTransparency = 0
                })
            end
            Window.ActiveTab = Tab
            
            if Tab.ActiveSubTab then
                Window.ActiveView = Tab.ActiveSubTab
            else
                Window.ActiveView = Tab
            end
            
            -- Re-apply search filter
            local q = SearchBox.Text:lower()
            for _, el in ipairs(Window.ActiveView.Elements) do
                if el.Frame then
                    el.Frame.Visible = (q == "" or el.Name:lower():find(q, 1, true) ~= nil)
                end
            end
        end)

        Tab.Frame = TabFrame
        Tab.Button = TabBtn
        table.insert(Window.Tabs, Tab)
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then TabBtn.MouseButton1Click:Fire() end

        return Tab
    end

    -- Toast Notification Hook
    function Window:Notify(notifyConfig)
        Notification.Notify(ScreenGui, notifyConfig)
    end

    Window.ScreenGui = ScreenGui
    return Window
end

return WindowModule