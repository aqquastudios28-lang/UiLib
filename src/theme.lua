--// theme.lua
--// Central design-token module for Obsidian — "premium black glass".
--// Every color / radius / stroke / glow in the redesign is defined here so the
--// whole look can be tuned from one place (and so the accent can be re-themed
--// at runtime later). Kept old-Luau compatible: plain tables + functions only,
--// no backtick strings / += / if-expressions / Font.new etc.

local Theme = {}

--============================================================================--
--  TOKENS
--============================================================================--

Theme.Color = {
    --// surfaces (near-black, slight blue bias so neutrals read as "chosen")
    WindowBase   = Color3.fromRGB(15, 16, 23),   -- main window fill
    Rail         = Color3.fromRGB(11, 12, 18),   -- left icon rail
    Subrail      = Color3.fromRGB(14, 15, 22),   -- subtab column
    Panel        = Color3.fromRGB(20, 21, 30),   -- section panels
    Card         = Color3.fromRGB(26, 27, 37),   -- control backgrounds
    CardHover    = Color3.fromRGB(36, 38, 51),   -- hovered control
    Input        = Color3.fromRGB(30, 31, 42),   -- textbox / slider track / keycap

    --// text
    Text         = Color3.fromRGB(237, 238, 246),
    TextSub      = Color3.fromRGB(156, 159, 178),
    TextMuted    = Color3.fromRGB(103, 106, 126),
    Placeholder  = Color3.fromRGB(110, 113, 132),

    --// accent (indigo) + glow
    Accent       = Color3.fromRGB(140, 142, 255),
    Accent2      = Color3.fromRGB(106, 111, 224),
    AccentDeep   = Color3.fromRGB(75, 80, 184),

    --// semantic (kept separate from accent)
    Success      = Color3.fromRGB(87, 217, 163),
    SuccessDeep  = Color3.fromRGB(57, 181, 134),
    Danger       = Color3.fromRGB(245, 115, 124),
    DangerDeep   = Color3.fromRGB(198, 84, 92),
    Warning      = Color3.fromRGB(245, 197, 107),

    --// strokes / dividers
    Stroke       = Color3.fromRGB(255, 255, 255), -- hairline (used with high transparency)
    Border       = Color3.fromRGB(48, 50, 66),    -- opaque-ish border / divider
    Divider      = Color3.fromRGB(38, 40, 54),

    Black        = Color3.fromRGB(0, 0, 0),
    White        = Color3.fromRGB(255, 255, 255)
}

--// transparencies (0 = solid, 1 = invisible)
Theme.Alpha = {
    Glass        = 0.04,   -- window base
    PanelGlass   = 0.06,   -- section panels
    Hairline     = 0.90,   -- subtle glass edge stroke
    HairlineHot  = 0.80,   -- brighter edge
    Sheen        = 0.94,   -- top highlight start
    Shadow       = 0.45,
    ShadowSoft   = 0.62,
    Glow         = 0.55
}

Theme.Radius = {
    Window = UDim.new(0, 14),
    Panel  = UDim.new(0, 11),
    Card   = UDim.new(0, 8),
    Small  = UDim.new(0, 6),
    Pill   = UDim.new(1, 0)
}

Theme.Font = {
    Bold     = Enum.Font.GothamBold,
    Semibold = Enum.Font.GothamSemibold,
    Regular  = Enum.Font.Gotham
}

Theme.Shadow = {
    Box  = "rbxassetid://6014261993", -- 9-slice soft box shadow
    Glow = "rbxassetid://6015897843", -- radial glow
    Slice = Rect.new(49, 49, 450, 450)
}

Theme.Tween = {
    Base  = TweenInfo.new(0.40, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
    Quick = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Back  = TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    In    = TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
}

--============================================================================--
--  HELPERS  (instance factories used by the new toast / modal code)
--============================================================================--

function Theme.corner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or Theme.Radius.Card
    c.Parent = inst
    return c
end

--// hairline glass edge
function Theme.stroke(inst, color, transparency, thickness, mode)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Color.Stroke
    s.Transparency = transparency == nil and Theme.Alpha.Hairline or transparency
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

--// vertical top-highlight that fakes glass (no real backdrop blur in Roblox)
function Theme.sheen(parent, height)
    local f = Instance.new("Frame")
    f.Name = "Sheen"
    f.BackgroundColor3 = Theme.Color.White
    f.BorderSizePixel = 0
    f.Size = UDim2.new(1, 0, height or 0.5, 0)
    f.ZIndex = (parent.ZIndex or 1)

    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, Theme.Alpha.Sheen),
        NumberSequenceKeypoint.new(1, 1)
    })
    g.Parent = f

    -- inherit the parent's rounding so the sheen doesn't spill past corners
    local pc = parent:FindFirstChildOfClass("UICorner")
    if pc then
        local c = Instance.new("UICorner")
        c.CornerRadius = pc.CornerRadius
        c.Parent = f
    end

    f.Parent = parent
    return f
end

--// soft 9-slice drop shadow behind a rounded box
function Theme.shadow(parent, spread, transparency)
    local holder = Instance.new("Frame")
    holder.Name = "DropShadowHolder"
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(1, 0, 1, 0)
    holder.ZIndex = 0

    local s = Instance.new("ImageLabel")
    s.Name = "DropShadow"
    s.AnchorPoint = Vector2.new(0.5, 0.5)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.Position = UDim2.new(0.5, 0, 0.5, 3)
    s.Size = UDim2.new(1, spread or 34, 1, spread or 34)
    s.ZIndex = 0
    s.Image = Theme.Shadow.Box
    s.ImageColor3 = Theme.Color.Black
    s.ImageTransparency = transparency == nil and Theme.Alpha.Shadow or transparency
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Theme.Shadow.Slice
    s.Parent = holder

    holder.Parent = parent
    return holder
end

--// radial accent glow behind an element
function Theme.glow(parent, color, spread, transparency)
    local g = Instance.new("ImageLabel")
    g.Name = "Glow"
    g.AnchorPoint = Vector2.new(0.5, 0.5)
    g.BackgroundTransparency = 1
    g.BorderSizePixel = 0
    g.Position = UDim2.new(0.5, 0, 0.5, 0)
    g.Size = UDim2.new(1, spread or 40, 1, spread or 40)
    g.ZIndex = 0
    g.Image = Theme.Shadow.Glow
    g.ImageColor3 = color or Theme.Color.Accent
    g.ImageTransparency = transparency == nil and Theme.Alpha.Glow or transparency
    g.ScaleType = Enum.ScaleType.Slice
    g.SliceCenter = Theme.Shadow.Slice
    g.Parent = parent
    return g
end

--// vertical accent gradient (for accent bars / fills)
function Theme.accentGradient(inst, rotation)
    local g = Instance.new("UIGradient")
    g.Rotation = rotation or 90
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Color.Accent),
        ColorSequenceKeypoint.new(1, Theme.Color.Accent2)
    })
    g.Parent = inst
    return g
end

return Theme
