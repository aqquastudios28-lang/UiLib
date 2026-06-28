-- src/core/theme.lua
-- Premium Obsidian/Cyan Dark Theme for QwenUILib

return {
    -- Base Colors (Obsidian Dark with Vibrant Cyan Accents)
    Background = Color3.fromRGB(10, 10, 14),
    Glass = Color3.fromRGB(18, 18, 26),
    GlassLight = Color3.fromRGB(28, 28, 40),
    Accent = Color3.fromRGB(0, 180, 255),
    AccentHover = Color3.fromRGB(30, 200, 255),
    AccentDim = Color3.fromRGB(0, 120, 180),
    
    -- Text Colors
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(170, 175, 190),
    Muted = Color3.fromRGB(100, 105, 120),
    
    -- Glass Effect Properties
    GlassTransparency = 0.55, -- Slightly more visible for liquid neon contrast
    GlassBorder = Color3.fromRGB(45, 45, 62),
    GlassHighlight = Color3.fromRGB(255, 255, 255),
    
    -- Shadows & Depth
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.65,
    
    -- Fonts
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    FontLight = Enum.Font.Gotham,
    
    -- Animation
    TweenTime = 0.2,
    EasingStyle = Enum.EasingStyle.Quart,
    EasingDirection = Enum.EasingDirection.Out
}