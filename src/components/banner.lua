-- src/components/banner.lua
local Theme = require(script.Parent.Parent.core.theme)
local Utils = require(script.Parent.Parent.core.utils)

return function(Tab, imageAsset, height)
    height = height or 120
    
    -- Main Frame (Glass border frame)
    local Frame = Instance.new("Frame", Tab.Frame)
    Frame.Size = UDim2.new(1, 0, 0, height)
    Frame.BackgroundColor3 = Theme.Glass
    Frame.BackgroundTransparency = 0.5
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 2
    Utils.Corner(Frame, 8)
    Utils.GlassBorder(Frame, 1.2)
    
    -- Banner Image Label
    local Image = Instance.new("ImageLabel", Frame)
    Image.Size = UDim2.new(1, -6, 1, -6)
    Image.Position = UDim2.new(0, 3, 0, 3)
    Image.BackgroundTransparency = 1
    Image.Image = imageAsset or "rbxassetid://0"
    Image.ScaleType = Enum.ScaleType.Crop
    Image.ZIndex = 3
    Utils.Corner(Image, 6)
    
    table.insert(Tab.Elements, { Frame = Frame, Name = "Banner" })
    
    return {
        SetImage = function(img)
            Image.Image = img
        end,
        Frame = Frame
    }
end
