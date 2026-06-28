-- src/core/window.lua
local Theme = require(script.Parent.theme)
local Utils = require(script.Parent.utils)
local Notification = require(script.Parent.notification)
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
    
    if syn and syn.protect_gui then 
        syn.protect_gui(ScreenGui) 
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif gethui then 
        ScreenGui.Parent = gethui() 
    else 
        ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui 
    end

    -- Shadow Layer
    local Shadow = Instance.new("Frame", ScreenGui)
    Shadow.Size = config.Size or UDim2.new(0, 620, 0, 460)
    Shadow.Position = UDim2.new(0.5, -310, 0.5, -230)
    Shadow.BackgroundTransparency = 1
    Utils.CreateShadow(Shadow, UDim2.new(1, 20, 1, 20), UDim2.new(0, -10, 0, -10), 0.65)

    -- Main Frame (Obsidian Dark Glass)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = config.Size or UDim2.new(0, 620, 0, 460)
    Main.Position = UDim2.new(0.5, -310, 0.5, -230)
    Main.BackgroundColor3 = Theme.Background
    Main.BackgroundTransparency = 0.12
    Main.BorderSizePixel = 0
    Utils.Corner(Main, 12)
    Utils.GlassBorder(Main, 1.5)
    Utils.MakeDraggable(Main, Main)

    -- Liquid Neon Background Blobs
    local Blob1 = Utils.CreateGlowBlob(Main, Theme.Accent, UDim2.new(0, 260, 0, 260), UDim2.new(-0.2, 0, -0.2, 0))
    local Blob2 = Utils.CreateGlowBlob(Main, Color3.fromRGB(180, 0, 255), UDim2.new(0, 300, 0, 300), UDim2.new(0.6, 0, 0.5, 0))
    
    -- Animate Neon Blobs (Liquid Flow)
    task.spawn(function()
        local startTime = os.clock()
        while task.wait(0.04) do
            if not Main or not Main.Parent then break end
            local t = os.clock() - startTime
            local x1 = -0.15 + 0.12 * math.sin(t * 0.4)
            local y1 = -0.15 + 0.12 * math.cos(t * 0.3)
            local x2 = 0.55 + 0.12 * math.cos(t * 0.25)
            local y2 = 0.45 + 0.12 * math.sin(t * 0.35)
            Blob1.Position = UDim2.new(x1, 0, y1, 0)
            Blob2.Position = UDim2.new(x2, 0, y2, 0)
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
    SearchContainer.Position = UDim2.new(1, -195, 0.5, -14)
    SearchContainer.BackgroundColor3 = Theme.Glass
    SearchContainer.BackgroundTransparency = 0.75
    SearchContainer.ZIndex = 4
    Utils.Corner(SearchContainer, 6)
    Utils.GlassBorder(SearchContainer, 0.8)

    local SearchIcon = Instance.new("TextLabel", SearchContainer)
    SearchIcon.Size = UDim2.new(0, 24, 1, 0)
    SearchIcon.Position = UDim2.new(0, 8, 0, 0)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Text = "🔍"
    SearchIcon.TextSize = 12
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

    ScreenGui.Destroying:Connect(function()
        if toggleConnection then
            toggleConnection:Disconnect()
            toggleConnection = nil
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
        TabBtn.Text = (icon and icon .. "  " or "") .. name
        TabBtn.TextColor3 = Theme.SubText
        TabBtn.TextSize = 12
        TabBtn.Font = Theme.Font
        TabBtn.AutoButtonColor = false
        TabBtn.ZIndex = 3
        Utils.Corner(TabBtn, 6)
        Utils.GlassBorder(TabBtn, 0.8)
        
        if groupParent then
            -- Position below group parent in LayoutOrder if sorted
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
                end
                SubFrame.Visible = true
                Utils.Tween(SubBtn, 0.2, {
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.4,
                    TextColor3 = Theme.Text
                })
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
                    BackgroundTransparency = 0.75,
                    TextColor3 = Theme.SubText
                })
            end
            TabFrame.Visible = true
            Utils.Tween(TabBtn, 0.2, {
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.35,
                TextColor3 = Theme.Text
            })
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