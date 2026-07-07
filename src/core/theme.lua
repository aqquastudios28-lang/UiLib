-- QwenUILib Theme System
-- Charcoal/OLED Dark theme with reactive Changed signals

local Theme = {}
Theme.__index = Theme

-- Core color palette
Theme.Colors = {
	-- Background layers
	BackgroundPrimary = Color3.fromHex("#0a0a0f"),      -- Deepest background
	BackgroundSecondary = Color3.fromHex("#12121a"),    -- Secondary background
	BackgroundTertiary = Color3.fromHex("#1a1a25"),     -- Tertiary background
	BackgroundHover = Color3.fromHex("#22222f"),        -- Hover state

	-- Accent colors
	AccentPrimary = Color3.fromHex("#7c3aed"),          -- Violet accent
	AccentSecondary = Color3.fromHex("#a78bfa"),        -- Light violet
	AccentGlow = Color3.fromHex("#7c3aed"),             -- Glow effect

	-- Text hierarchy
	TextPrimary = Color3.fromHex("#f5f5f7"),            -- Primary text
	TextSecondary = Color3.fromHex("#a1a1aa"),          -- Secondary text
	TextMuted = Color3.fromHex("#71717a"),              -- Muted text

	-- Semantic colors
	Success = Color3.fromHex("#22c55e"),                -- Success green
	Warning = Color3.fromHex("#f59e0b"),                -- Warning amber
	Error = Color3.fromHex("#ef4444"),                  -- Error red
	Info = Color3.fromHex("#3b82f6"),                   -- Info blue

	-- Borders and strokes
	BorderPrimary = Color3.fromHex("#27272a"),          -- Primary border
	BorderSecondary = Color3.fromHex("#3f3f46"),        -- Secondary border
	StrokePrimary = Color3.fromHex("#3f3f46"),          -- Stroke color
}

-- Transparency settings
Theme.Transparency = {
	BackgroundPrimary = 0.35,
	BackgroundSecondary = 0.45,
	BackgroundTertiary = 0.50,
	BackgroundHover = 0.40,
	Border = 0.60,
	Stroke = 0.80,
	Glass = 0.15,
}

-- Corner radius presets
Theme.CornerRadius = {
	WindowOuter = 16,
	WindowInner = 10,
	WidgetOuter = 10,
	WidgetInner = 7,
	Button = 8,
	Small = 4,
}

-- Typography
Theme.Font = {
	Family = Enum.Font.Gotham,
	Size = {
		Title = 18,
		Header = 16,
		Body = 14,
		Small = 12,
		Tiny = 10,
	},
	Weight = {
		Regular = Enum.FontWeight.Regular,
		Medium = Enum.FontWeight.Medium,
		Semibold = Enum.FontWeight.SemiBold,
		Bold = Enum.FontWeight.Bold,
	},
}

-- Spacing scale (pixels)
Theme.Spacing = {
	XS = 4,
	SM = 8,
	MD = 12,
	LG = 16,
	XL = 20,
	XXL = 24,
}

-- Animation settings
Theme.Animation = {
	Duration = {
		Fast = 0.15,
		Normal = 0.25,
		Slow = 0.40,
	},
	Easing = {
		Style = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out,
	},
}

-- Icon presets
Theme.Presets = {
	Phosphor = "Phosphor",
	Material = "Material",
	Custom = "Custom",
}

-- Current active preset
Theme.ActivePreset = Theme.Presets.Phosphor

-- Reactive Changed signal system (pure Lua)
local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_connections = {},
		_nextId = 1,
	}, Signal)
end

function Signal:Connect(callback)
	local id = self._nextId
	self._nextId += 1
	self._connections[id] = callback

	return {
		Disconnect = function()
			self._connections[id] = nil
		end,
	}
end

function Signal:Fire(...)
	for _, callback in pairs(self._connections) do
		task.spawn(callback, ...)
	end
end

function Signal:Destroy()
	table.clear(self._connections)
end

-- Property change signals
Theme.Changed = Signal.new()

-- Reactive property getter/setter
function Theme:GetColor(name)
	return self.Colors[name]
end

function Theme:SetColor(name, value)
	if self.Colors[name] ~= value then
		self.Colors[name] = value
		self.Changed:Fire("Color", name, value)
	end
end

function Theme:GetTransparency(name)
	return self.Transparency[name]
end

function Theme:ApplyPreset(presetName)
	if self.Presets[presetName] then
		self.ActivePreset = presetName
		self.Changed:Fire("Preset", presetName)
	end
end

-- Initialize default signals
Theme.OnColorChanged = Signal.new()
Theme.OnPresetChanged = Signal.new()

-- Connect master changed signal to specific signals
Theme.Changed:Connect(function(changeType, name, value)
	if changeType == "Color" then
		Theme.OnColorChanged:Fire(name, value)
	elseif changeType == "Preset" then
		Theme.OnPresetChanged:Fire(value)
	end
end)

-- Export theme constants for easy access
Theme.Dark = Theme.Colors
Theme.Light = {
	BackgroundPrimary = Color3.fromHex("#fafafa"),
	BackgroundSecondary = Color3.fromHex("#f5f5f5"),
	BackgroundTertiary = Color3.fromHex("#e5e5e5"),
	BackgroundHover = Color3.fromHex("#d4d4d4"),
	AccentPrimary = Color3.fromHex("#7c3aed"),
	AccentSecondary = Color3.fromHex("#6d28d9"),
	AccentGlow = Color3.fromHex("#7c3aed"),
	TextPrimary = Color3.fromHex("#171717"),
	TextSecondary = Color3.fromHex("#525252"),
	TextMuted = Color3.fromHex("#737373"),
	Success = Color3.fromHex("#16a34a"),
	Warning = Color3.fromHex("#d97706"),
	Error = Color3.fromHex("#dc2626"),
	Info = Color3.fromHex("#2563eb"),
	BorderPrimary = Color3.fromHex("#e5e5e5"),
	BorderSecondary = Color3.fromHex("#d4d4d4"),
	StrokePrimary = Color3.fromHex("#a3a3a3"),
}

return Theme