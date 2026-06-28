-- src/components/dropdown.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)
local UIS = game:GetService("UserInputService")

return function(Tab, name, options, default, callback)
    options = options or {}
    local selected = default or options[1] or ""
    callback = callback or function() end
    
    local isOpen = false
    local optionButtons = {}
    
    -- Main Dropdown Frame (Glass)
    local Frame = Instance.new("Frame", Tab.Frame)
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = Theme.Glass
    Frame.BackgroundTransparency = 0.75
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.ZIndex = 20
    Utils.Corner(Frame, 8)
    Utils.GlassBorder(Frame, 0.8)

    -- Header (Clickable Area)
    local Header = Instance.new("TextButton", Frame)
    Header.Size = UDim2.new(1, 0, 0, 38)
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.ZIndex = 21

    -- Title Label
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(0.5, -15, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.TextColor3 = Theme.SubText
    Title.TextSize = 13
    Title.Font = Theme.Font
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 22

    -- Selected Option Display
    local ValueText = Instance.new("TextLabel", Header)
    ValueText.Size = UDim2.new(0.5, -25, 1, 0)
    ValueText.Position = UDim2.new(0.5, 0, 0, 0)
    ValueText.BackgroundTransparency = 1
    ValueText.Text = selected
    ValueText.TextColor3 = Theme.Text
    ValueText.TextSize = 13
    ValueText.Font = Theme.FontBold
    ValueText.TextXAlignment = Enum.TextXAlignment.Right
    ValueText.ZIndex = 22

    -- Dropdown Arrow
    local Arrow = Instance.new("TextLabel", Header)
    Arrow.Size = UDim2.new(0, 24, 1, 0)
    Arrow.Position = UDim2.new(1, -30, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = Theme.Accent
    Arrow.TextSize = 11
    Arrow.Font = Theme.FontBold
    Arrow.ZIndex = 22

    -- Dropdown Menu Container (Hidden initially)
    local Menu = Instance.new("Frame", Frame)
    Menu.Size = UDim2.new(1, 0, 0, 150)
    Menu.Position = UDim2.new(0, 0, 0, 38)
    Menu.BackgroundTransparency = 1
    Menu.ZIndex = 20

    -- Option List Search Bar (Premium search capability)
    local SearchBox = Instance.new("TextBox", Menu)
    SearchBox.Size = UDim2.new(1, -20, 0, 24)
    SearchBox.Position = UDim2.new(0, 10, 0, 4)
    SearchBox.BackgroundColor3 = Theme.GlassLight
    SearchBox.BackgroundTransparency = 0.7
    SearchBox.PlaceholderText = "Search options..."
    SearchBox.PlaceholderColor3 = Theme.Muted
    SearchBox.TextColor3 = Theme.Text
    SearchBox.TextSize = 11
    SearchBox.Font = Theme.Font
    SearchBox.Text = ""
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 22
    Utils.Corner(SearchBox, 4)
    Utils.GlassBorder(SearchBox, 0.6)

    -- Options Scrolling List
    local Scroll = Instance.new("ScrollingFrame", Menu)
    Scroll.Size = UDim2.new(1, -12, 0, 110)
    Scroll.Position = UDim2.new(0, 6, 0, 34)
    Scroll.BackgroundTransparency = 1
    Scroll.ZIndex = 21
    Utils.StyleScroll(Scroll)

    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.Padding = UDim.new(0, 4)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local Pad = Instance.new("UIPadding", Scroll)
    Pad.PaddingLeft = UDim.new(0, 4)
    Pad.PaddingRight = UDim.new(0, 4)
    Pad.PaddingTop = UDim.new(0, 4)

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)

    -- Redraw Option Buttons
    local function RenderOptions()
        -- Clear old buttons
        for _, btn in ipairs(optionButtons) do
            btn:Destroy()
        end
        table.clear(optionButtons)

        local query = SearchBox.Text:lower()
        for idx, option in ipairs(options) do
            if query == "" or tostring(option):lower():find(query, 1, true) then
                local OptBtn = Instance.new("TextButton", Scroll)
                OptBtn.Size = UDim2.new(1, 0, 0, 24)
                OptBtn.BackgroundColor3 = (selected == option) and Theme.Accent or Theme.GlassLight
                OptBtn.BackgroundTransparency = (selected == option) and 0.4 or 0.8
                OptBtn.Text = tostring(option)
                OptBtn.TextColor3 = (selected == option) and Theme.Text or Theme.SubText
                OptBtn.TextSize = 12
                OptBtn.Font = (selected == option) and Theme.FontBold or Theme.Font
                OptBtn.AutoButtonColor = false
                OptBtn.ZIndex = 23
                Utils.Corner(OptBtn, 4)
                Utils.GlassBorder(OptBtn, 0.5)

                -- Hover Effect
                OptBtn.MouseEnter:Connect(function()
                    if selected ~= option then
                        Utils.Tween(OptBtn, 0.15, {BackgroundTransparency = 0.6, TextColor3 = Theme.Text})
                    end
                end)
                OptBtn.MouseLeave:Connect(function()
                    if selected ~= option then
                        Utils.Tween(OptBtn, 0.15, {BackgroundTransparency = 0.8, TextColor3 = Theme.SubText})
                    end
                end)

                -- Select Effect
                OptBtn.MouseButton1Click:Connect(function()
                    selected = option
                    ValueText.Text = tostring(option)
                    
                    -- Close dropdown
                    isOpen = false
                    Utils.Tween(Frame, 0.25, {Size = UDim2.new(1, 0, 0, 38)})
                    Utils.Tween(Arrow, 0.25, {Rotation = 0})
                    
                    task.spawn(callback, option)
                    RenderOptions()
                end)

                table.insert(optionButtons, OptBtn)
            end
        end
    end

    -- Toggle Dropdown Menu
    Header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            SearchBox.Text = ""
            RenderOptions()
            Utils.Tween(Frame, 0.25, {Size = UDim2.new(1, 0, 0, 192)})
            Utils.Tween(Arrow, 0.25, {Rotation = 180})
        else
            Utils.Tween(Frame, 0.25, {Size = UDim2.new(1, 0, 0, 38)})
            Utils.Tween(Arrow, 0.25, {Rotation = 0})
        end
    end)

    -- Dynamic Search filter connection
    SearchBox:GetPropertyChangedSignal("Text"):Connect(RenderOptions)

    -- Set Default value
    RenderOptions()

    table.insert(Tab.Elements, { Frame = Frame, Name = name })

    return {
        Set = function(v)
            selected = v
            ValueText.Text = tostring(v)
            RenderOptions()
            task.spawn(callback, v)
        end,
        Get = function() return selected end,
        Refresh = function(newOptions)
            options = newOptions or {}
            if not table.find(options, selected) then
                selected = options[1] or ""
                ValueText.Text = tostring(selected)
            end
            RenderOptions()
        end
    }
end
