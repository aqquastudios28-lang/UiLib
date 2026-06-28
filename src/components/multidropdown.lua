-- src/components/multidropdown.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)

return function(Tab, name, options, defaultSelected, callback)
    options = options or {}
    defaultSelected = defaultSelected or {}
    callback = callback or function() end
    
    local selected = {}
    for _, item in ipairs(defaultSelected) do
        selected[item] = true
    end
    
    local isOpen = false
    local optionButtons = {}
    
    -- Main Frame (Glass)
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

    -- Selected Display (Joined list of options)
    local ValueText = Instance.new("TextLabel", Header)
    ValueText.Size = UDim2.new(0.5, -25, 1, 0)
    ValueText.Position = UDim2.new(0.5, 0, 0, 0)
    ValueText.BackgroundTransparency = 1
    ValueText.TextColor3 = Theme.Text
    ValueText.TextSize = 12
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

    -- Menu Container
    local Menu = Instance.new("Frame", Frame)
    Menu.Size = UDim2.new(1, 0, 0, 150)
    Menu.Position = UDim2.new(0, 0, 0, 38)
    Menu.BackgroundTransparency = 1
    Menu.ZIndex = 20

    -- Search Bar
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

    -- Scroll List
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

    -- Helper to get selected values list
    local function GetSelectedValues()
        local list = {}
        for _, item in ipairs(options) do
            if selected[item] then
                table.insert(list, item)
            end
        end
        return list
    end

    local function UpdateText()
        local selectedList = GetSelectedValues()
        if #selectedList == 0 then
            ValueText.Text = "None"
        elseif #selectedList == #options then
            ValueText.Text = "All"
        else
            ValueText.Text = table.concat(selectedList, ", ")
        end
    end

    -- Render Options inside Scroll
    local function RenderOptions()
        for _, btn in ipairs(optionButtons) do
            btn:Destroy()
        end
        table.clear(optionButtons)

        local query = SearchBox.Text:lower()
        for _, option in ipairs(options) do
            if query == "" or tostring(option):lower():find(query, 1, true) then
                local isOptSelected = selected[option] == true

                local OptBtn = Instance.new("TextButton", Scroll)
                OptBtn.Size = UDim2.new(1, 0, 0, 24)
                OptBtn.BackgroundColor3 = isOptSelected and Theme.Accent or Theme.GlassLight
                OptBtn.BackgroundTransparency = isOptSelected and 0.4 or 0.8
                OptBtn.Text = ""
                OptBtn.AutoButtonColor = false
                OptBtn.ZIndex = 23
                Utils.Corner(OptBtn, 4)
                Utils.GlassBorder(OptBtn, 0.5)

                -- Option text label
                local Label = Instance.new("TextLabel", OptBtn)
                Label.Size = UDim2.new(1, -30, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = tostring(option)
                Label.TextColor3 = isOptSelected and Theme.Text or Theme.SubText
                Label.TextSize = 12
                Label.Font = isOptSelected and Theme.FontBold or Theme.Font
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.ZIndex = 24

                -- Checkmark checkbox
                local Checkbox = Instance.new("TextLabel", OptBtn)
                Checkbox.Size = UDim2.new(0, 20, 0, 20)
                Checkbox.Position = UDim2.new(1, -24, 0.5, -10)
                Checkbox.BackgroundTransparency = 1
                Checkbox.Text = isOptSelected and "✓" or ""
                Checkbox.TextColor3 = Theme.Text
                Checkbox.TextSize = 12
                Checkbox.Font = Theme.FontBold
                Checkbox.ZIndex = 24

                -- Hover Effect
                OptBtn.MouseEnter:Connect(function()
                    if not selected[option] then
                        Utils.Tween(OptBtn, 0.15, {BackgroundTransparency = 0.6})
                        Utils.Tween(Label, 0.15, {TextColor3 = Theme.Text})
                    end
                end)
                OptBtn.MouseLeave:Connect(function()
                    if not selected[option] then
                        Utils.Tween(OptBtn, 0.15, {BackgroundTransparency = 0.8})
                        Utils.Tween(Label, 0.15, {TextColor3 = Theme.SubText})
                    end
                end)

                -- Click handler
                OptBtn.MouseButton1Click:Connect(function()
                    selected[option] = not selected[option]
                    if not selected[option] then selected[option] = nil end -- clean key
                    
                    UpdateText()
                    task.spawn(callback, GetSelectedValues())
                    RenderOptions()
                end)

                table.insert(optionButtons, OptBtn)
            end
        end
    end

    -- Toggle dropdown menu
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

    SearchBox:GetPropertyChangedSignal("Text"):Connect(RenderOptions)

    UpdateText()
    RenderOptions()

    table.insert(Tab.Elements, { Frame = Frame, Name = name })

    return {
        Set = function(newSelection)
            table.clear(selected)
            for _, item in ipairs(newSelection) do
                selected[item] = true
            end
            UpdateText()
            RenderOptions()
            task.spawn(callback, GetSelectedValues())
        end,
        Get = function() return GetSelectedValues() end,
        Refresh = function(newOptions)
            options = newOptions or {}
            -- Clear selected items that are no longer valid options
            for k, _ in pairs(selected) do
                if not table.find(options, k) then
                    selected[k] = nil
                end
            end
            UpdateText()
            RenderOptions()
        end
    }
end
