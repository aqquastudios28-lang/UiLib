-- src/components/console.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)

return function(Tab, name)
    local logs = {}
    local logObjects = {}
    
    -- Main Container (Glass)
    local Frame = Instance.new("Frame", Tab.Frame)
    Frame.Size = UDim2.new(1, 0, 0, 180)
    Frame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    Frame.BackgroundTransparency = 0.5
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 2
    Utils.Corner(Frame, 8)
    Utils.GlassBorder(Frame, 0.8)

    -- Header Panel
    local Header = Instance.new("Frame", Frame)
    Header.Size = UDim2.new(1, 0, 0, 28)
    Header.BackgroundColor3 = Theme.GlassLight
    Header.BackgroundTransparency = 0.7
    Header.BorderSizePixel = 0
    Header.ZIndex = 3
    Utils.Corner(Header, 8)
    
    -- Cut off bottom corners of header
    local HeaderCut = Instance.new("Frame", Header)
    HeaderCut.Size = UDim2.new(1, 0, 0, 4)
    HeaderCut.Position = UDim2.new(0, 0, 1, -4)
    HeaderCut.BackgroundColor3 = Theme.GlassLight
    HeaderCut.BackgroundTransparency = 0.7
    HeaderCut.BorderSizePixel = 0
    HeaderCut.ZIndex = 3

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(0.3, 0, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name or "Console"
    Title.TextColor3 = Theme.Text
    Title.TextSize = 11
    Title.Font = Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 4

    -- Console Action Buttons (Clear, Copy)
    local ClearBtn = Instance.new("TextButton", Header)
    ClearBtn.Size = UDim2.new(0, 48, 0, 18)
    ClearBtn.Position = UDim2.new(1, -120, 0.5, -9)
    ClearBtn.BackgroundColor3 = Theme.Glass
    ClearBtn.BackgroundTransparency = 0.6
    ClearBtn.Text = "Clear"
    ClearBtn.TextColor3 = Theme.SubText
    ClearBtn.TextSize = 10
    ClearBtn.Font = Theme.Font
    ClearBtn.AutoButtonColor = false
    ClearBtn.ZIndex = 4
    Utils.Corner(ClearBtn, 4)
    Utils.GlassBorder(ClearBtn, 0.5)

    local CopyBtn = Instance.new("TextButton", Header)
    CopyBtn.Size = UDim2.new(0, 48, 0, 18)
    CopyBtn.Position = UDim2.new(1, -64, 0.5, -9)
    CopyBtn.BackgroundColor3 = Theme.Glass
    CopyBtn.BackgroundTransparency = 0.6
    CopyBtn.Text = "Copy"
    CopyBtn.TextColor3 = Theme.SubText
    CopyBtn.TextSize = 10
    CopyBtn.Font = Theme.Font
    CopyBtn.AutoButtonColor = false
    CopyBtn.ZIndex = 4
    Utils.Corner(CopyBtn, 4)
    Utils.GlassBorder(CopyBtn, 0.5)

    -- Mini search box in console header
    local SearchBox = Instance.new("TextBox", Header)
    SearchBox.Size = UDim2.new(0, 100, 0, 18)
    SearchBox.Position = UDim2.new(1, -230, 0.5, -9)
    SearchBox.BackgroundColor3 = Theme.Glass
    SearchBox.BackgroundTransparency = 0.6
    SearchBox.PlaceholderText = "Filter logs..."
    SearchBox.PlaceholderColor3 = Theme.Muted
    SearchBox.TextColor3 = Theme.Text
    SearchBox.TextSize = 10
    SearchBox.Font = Theme.Font
    SearchBox.Text = ""
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 4
    Utils.Corner(SearchBox, 4)
    Utils.GlassBorder(SearchBox, 0.5)

    -- Scrollable Log Viewport
    local LogScroll = Instance.new("ScrollingFrame", Frame)
    LogScroll.Size = UDim2.new(1, -12, 1, -38)
    LogScroll.Position = UDim2.new(0, 6, 0, 32)
    LogScroll.BackgroundTransparency = 1
    LogScroll.ZIndex = 3
    Utils.StyleScroll(LogScroll)

    local Layout = Instance.new("UIListLayout", LogScroll)
    Layout.Padding = UDim.new(0, 2)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local Pad = Instance.new("UIPadding", LogScroll)
    Pad.PaddingLeft = UDim.new(0, 6)
    Pad.PaddingRight = UDim.new(0, 6)
    Pad.PaddingTop = UDim.new(0, 4)

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        LogScroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)

    local function ApplyFilter()
        local query = SearchBox.Text:lower()
        for idx, line in ipairs(logs) do
            local obj = logObjects[idx]
            if obj then
                local matches = (query == "") or line.Text:lower():find(query, 1, true)
                obj.Visible = matches
            end
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(ApplyFilter)

    local function Log(text, logType)
        logType = logType or "info"
        local timeStr = os.date("%H:%M:%S")
        local fullText = string.format("[%s] %s", timeStr, text)
        
        local color = Theme.Text
        if logType == "warn" then
            color = Color3.fromRGB(255, 180, 50)
        elseif logType == "error" then
            color = Color3.fromRGB(255, 80, 80)
        elseif logType == "success" then
            color = Color3.fromRGB(80, 255, 80)
        elseif logType == "info" then
            color = Theme.Accent
        end

        local logData = { Text = fullText, Color = color, Raw = text }
        table.insert(logs, logData)

        local LineLabel = Instance.new("TextLabel", LogScroll)
        LineLabel.Size = UDim2.new(1, 0, 0, 16)
        LineLabel.BackgroundTransparency = 1
        LineLabel.Text = fullText
        LineLabel.TextColor3 = color
        LineLabel.TextSize = 10
        LineLabel.Font = Enum.Font.Code
        LineLabel.TextXAlignment = Enum.TextXAlignment.Left
        LineLabel.TextWrapped = true
        LineLabel.AutomaticSize = Enum.AutomaticSize.Y
        LineLabel.ZIndex = 4
        
        table.insert(logObjects, LineLabel)
        ApplyFilter()

        -- Auto scroll to bottom
        task.defer(function()
            LogScroll.CanvasPosition = Vector2.new(0, LogScroll.CanvasSize.Y.Offset)
        end)
    end

    local function Clear()
        for _, obj in ipairs(logObjects) do
            obj:Destroy()
        end
        table.clear(logs)
        table.clear(logObjects)
    end

    ClearBtn.MouseButton1Click:Connect(Clear)

    CopyBtn.MouseButton1Click:Connect(function()
        local fullOutput = {}
        for _, log in ipairs(logs) do
            table.insert(fullOutput, log.Text)
        end
        local outputText = table.concat(fullOutput, "\n")
        
        if setclipboard then
            setclipboard(outputText)
            -- Show visual copy success
            CopyBtn.Text = "Copied!"
            task.delay(1.5, function() CopyBtn.Text = "Copy" end)
        else
            -- Notification fallback
            local ScreenGui = Tab.Frame:FindFirstAncestorOfClass("ScreenGui")
            if ScreenGui then
                Utils.Tween(CopyBtn, 0.1, {TextColor3 = Color3.fromRGB(255, 80, 80)})
                task.delay(1.5, function() CopyBtn.TextColor3 = Theme.SubText end)
            end
        end
    end)

    -- Hover animations for action buttons
    Utils.HoverEffect(ClearBtn, Theme.GlassLight, Theme.Glass)
    Utils.HoverEffect(CopyBtn, Theme.GlassLight, Theme.Glass)

    table.insert(Tab.Elements, { Frame = Frame, Name = name })

    return {
        Log = Log,
        Clear = Clear,
        Frame = Frame
    }
end
