-- src/components/row.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)

return function(Tab)
    -- Row Container (Transparent)
    local Frame = Instance.new("Frame", Tab.Frame)
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 2

    local Layout = Instance.new("UIListLayout", Frame)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Automatically resize children to fill horizontal space evenly
    local function resizeChildren()
        local children = {}
        for _, child in ipairs(Frame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                table.insert(children, child)
            end
        end
        
        local count = #children
        if count > 0 then
            local spacing = Layout.Padding.Offset
            local totalSpacing = spacing * (count - 1)
            for _, child in ipairs(children) do
                -- We divide width evenly and preserve height
                child.Size = UDim2.new(1 / count, -totalSpacing / count, 1, 0)
            end
        end
    end

    Frame.ChildAdded:Connect(function(child)
        if child:IsA("Frame") or child:IsA("TextButton") then
            task.defer(resizeChildren)
        end
    end)

    Frame.ChildRemoved:Connect(function(child)
        task.defer(resizeChildren)
    end)

    table.insert(Tab.Elements, { Frame = Frame, Name = "Row" })

    return Frame
end
