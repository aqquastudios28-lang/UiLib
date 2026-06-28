-- src/core/theme.lua
-- Premium Obsidian/Cyan Dark Theme with Reactive Updates

local Theme = {
    Values = {
        -- Base Colors (Obsidian Dark with Vibrant Cyan Accents)
        Background = Color3.fromRGB(10, 10, 14),
        BackgroundTransparency = 0.35, -- Let neon blobs shine through beautifully
        Glass = Color3.fromRGB(18, 18, 26),
        GlassLight = Color3.fromRGB(28, 28, 40),
        GlassTransparency = 0.45, -- Enhanced transparency for glassmorphism
        Accent = Color3.fromRGB(0, 180, 255),
        AccentHover = Color3.fromRGB(30, 200, 255),
        AccentDim = Color3.fromRGB(0, 120, 180),
        
        -- Text Colors
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(170, 175, 190),
        Muted = Color3.fromRGB(100, 105, 120),
        
        -- Glass Effect Properties
        GlassBorder = Color3.fromRGB(45, 45, 62),
        GlassBorderTransparency = 0.4,
        GlassHighlight = Color3.fromRGB(255, 255, 255),
        
        -- Shadows & Depth
        ShadowColor = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.5,
        
        -- Fonts
        Font = Enum.Font.GothamMedium,
        FontBold = Enum.Font.GothamBold,
        FontLight = Enum.Font.Gotham,
        
        -- Animation
        TweenTime = 0.2,
        EasingStyle = Enum.EasingStyle.Quart,
        EasingDirection = Enum.EasingDirection.Out,
        
        -- Liquid Neon Blobs
        Blob1Color = Color3.fromRGB(0, 180, 255),
        Blob2Color = Color3.fromRGB(180, 0, 255),
        BlobTransparency = 0.72, -- Visible yet elegant
        BlobSpeed = 1.0,
    }
}

-- Simple reactive event listener system (Pure Lua Signal)
local Signal = { Listeners = {} }
function Signal:Connect(callback)
    table.insert(self.Listeners, callback)
    return {
        Disconnect = function()
            local idx = table.find(self.Listeners, callback)
            if idx then table.remove(self.Listeners, idx) end
        end
    }
end
function Signal:Fire(arg)
    for _, callback in ipairs(self.Listeners) do
        task.spawn(callback, arg)
    end
end

Theme.Changed = Signal

-- Update theme values and trigger event listeners
function Theme:Update(newValues)
    local oldTheme = {}
    for k, v in pairs(Theme.Values) do
        oldTheme[k] = v
    end

    for k, v in pairs(newValues) do
        if Theme.Values[k] ~= nil then
            Theme.Values[k] = v
        end
    end
    Theme.Changed:Fire(oldTheme)
end

-- Allow direct access to values (e.g., Theme.Accent)
setmetatable(Theme, {
    __index = function(_, key)
        return Theme.Values[key]
    end
})

return Theme