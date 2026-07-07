-- QwenUILib Icons System
-- Online chunky/filled Phosphor icon dictionary and register system

local Icons = {}
Icons.__index = Icons

-- Icon registry
Icons.Registry = {}
Icons.LoadedPresets = {}

-- Phosphor icon mappings (regular weight)
local PhosphorRegular = {
	["house"] = "rbxassetid://6031094667",
	["gear"] = "rbxassetid://6031094938",
	["user"] = "rbxassetid://6031095019",
	["bell"] = "rbxassetid://6031094764",
	["heart"] = "rbxassetid://6031094824",
	["star"] = "rbxassetid://6031095138",
	["search"] = "rbxassetid://6031095062",
	["plus"] = "rbxassetid://6031094585",
	["minus"] = "rbxassetid://6031094418",
	["x"] = "6031095195",
	["check"] = "rbxassetid://6031094687",
	["arrow-right"] = "rbxassetid://6031094536",
	["arrow-left"] = "rbxassetid://6031094523",
	["arrow-up"] = "rbxassetid://6031094548",
	["arrow-down"] = "rbxassetid://6031094510",
	["caret-down"] = "rbxassetid://6031094655",
	["caret-up"] = "rbxassetid://6031094660",
	["caret-left"] = "rbxassetid://6031094644",
	["caret-right"] = "rbxassetid://6031094650",
	["list"] = "rbxassetid://6031095368",
	["grid"] = "rbxassetid://6031094787",
	["menu"] = "rbxassetid://6031095383",
	["dots-three"] = "rbxassetid://6031094737",
	["dots-three-vertical"] = "rbxassetid://6031094744",
	["trash"] = "rbxassetid://6031095147",
	["pencil"] = "rbxassetid://6031094447",
	["eye"] = "rbxassetid://6031094764",
	["eye-slash"] = "rbxassetid://6031094776",
	["lock"] = "rbxassetid://6031095419",
	["lock-open"] = "rbxassetid://6031095426",
	["warning"] = "rbxassetid://6031095183",
	["info"] = "rbxassetid://6031094833",
	["question"] = "rbxassetid://6031095035",
	["lightning"] = "rbxassetid://6031095350",
	["fire"] = "rbxassetid://6031094781",
	["rocket"] = "rbxassetid://6031095053",
	["shield"] = "rbxassetid://6031095076",
	["bug"] = "rbxassetid://6031094627",
	["code"] = "rbxassetid://6031094709",
	["terminal"] = "rbxassetid://6031095133",
	["folder"] = "rbxassetid://6031094795",
	["file"] = "rbxassetid://6031094750",
	["image"] = "rbxassetid://6031094815",
	["video"] = "rbxassetid://6031095172",
	["music"] = "rbxassetid://6031095434",
	["microphone"] = "rbxassetid://6031095398",
	["speaker"] = "rbxassetid://6031095107",
	["camera"] = "rbxassetid://6031094638",
	["map-pin"] = "rbxassetid://6031095339",
	["globe"] = "rbxassetid://6031094803",
	["link"] = "rbxassetid://6031095346",
	["calendar"] = "rbxassetid://6031094632",
	["clock"] = "rbxassetid://6031094695",
	["chart-bar"] = "rbxassetid://6031094667",
	["currency-dollar"] = "rbxassetid://6031094720",
	["shopping-cart"] = "rbxassetid://6031095093",
	["ticket"] = "rbxassetid://6031095141",
	["bookmarks"] = "rbxassetid://6031094614",
	["book-open"] = "rbxassetid://6031094606",
	["puzzle-piece"] = "rbxassetid://6031095027",
	["game-controller"] = "rbxassetid://6031094844",
	["cube"] = "rbxassetid://6031094727",
	["database"] = "rbxassetid://6031094731",
	["cloud"] = "rbxassetid://6031094716",
	["wifi-high"] = "rbxassetid://6031095189",
	["devices"] = "rbxassetid://6031094700",
	["monitor"] = "rbxassetid://6031095405",
	["print"] = "rbxassetid://6031095012",
	["scissors"] = "rbxassetid://6031095068",
	["copy"] = "rbxassetid://6031094721",
	["clipboard-text"] = "rbxassetid://6031094691",
	["keyboard"] = "rbxassetid://6031094852",
	["mouse"] = "rbxassetid://6031095412",
	["download"] = "rbxassetid://6031094756",
	["upload"] = "rbxassetid://6031095164",
	["gear-six"] = "rbxassetid://6031094946",
	["sliders"] = "rbxassetid://6031095086",
	["palette"] = "rbxassetid://6031094437",
	["swatches"] = "rbxassetid://6031095123",
	["text-aa"] = "rbxassetid://6031095154",
	["text-t"] = "rbxassetid://6031095161",
	["text-b"] = "rbxassetid://6031094667",
	["text-italic"] = "rbxassetid://6031095159",
	["text-underline"] = "rbxassetid://6031095170",
	["text-strikethrough"] = "rbxassetid://6031095157",
	["list-bullets"] = "rbxassetid://6031095325",
	["list-numbers"] = "rbxassetid://6031095342",
	["indent"] = "rbxassetid://6031094857",
	["outdent"] = "rbxassetid://6031095440",
	["text-align-left"] = "rbxassetid://6031095441",
	["text-align-center"] = "rbxassetid://6031095442",
	["text-align-right"] = "rbxassetid://6031095443",
	["text-align-justify"] = "rbxassetid://6031095444",
	["sign-out"] = "rbxassetid://6031095080",
	["sign-in"] = "rbxassetid://6031095075",
	["user-plus"] = "rbxassetid://6031095212",
	["users"] = "rbxassetid://6031095201",
	["user-circle"] = "rbxassetid://6031095199",
	["identification"] = "rbxassetid://6031094849",
	["identification-card"] = "rbxassetid://6031094850",
	["phone"] = "rbxassetid://6031094475",
	["envelope"] = "rbxassetid://6031094764",
	["chats-circle"] = "rbxassetid://6031094680",
	["chat-dots"] = "rbxassetid://6031094673",
	["paper-plane"] = "rbxassetid://6031095437",
	["bell-ringing"] = "rbxassetid://6031094570",
	["bell-simple"] = "rbxassetid://6031094564",
	["bell-slash"] = "rbxassetid://6031094577",
	["magnifying-glass"] = "rbxassetid://6031095332",
	["funnel"] = "rbxassetid://6031094839",
	["slider"] = "rbxassetid://6031095098",
	["toggle-left"] = "rbxassetid://6031095151",
	["toggle-right"] = "rbxassetid://6031095155",
	["check-circle"] = "rbxassetid://6031094676",
	["x-circle"] = "rbxassetid://6031095206",
	["warning-circle"] = "rbxassetid://6031095186",
	["info"] = "rbxassetid://6031094835",
	["question"] = "rbxassetid://6031095038",
	["exclamation"] = "rbxassetid://6031094772",
}

-- Phosphor icon mappings (filled weight)
local PhosphorFilled = {
	["house"] = "rbxassetid://6031094674",
	["gear"] = "rbxassetid://6031094942",
	["user"] = "rbxassetid://6031095023",
	["bell"] = "rbxassetid://6031094768",
	["heart"] = "rbxassetid://6031094828",
	["star"] = "rbxassetid://6031095142",
	["search"] = "rbxassetid://6031095066",
	["plus"] = "rbxassetid://6031094589",
	["minus"] = "rbxassetid://6031094422",
	["x"] = "rbxassetid://6031095199",
	["check"] = "rbxassetid://6031094691",
	["arrow-right"] = "rbxassetid://6031094540",
	["arrow-left"] = "rbxassetid://6031094527",
	["arrow-up"] = "rbxassetid://6031094552",
	["arrow-down"] = "rbxassetid://6031094514",
	["caret-down"] = "rbxassetid://6031094659",
	["caret-up"] = "rbxassetid://6031094664",
	["caret-left"] = "rbxassetid://6031094648",
	["caret-right"] = "rbxassetid://6031094654",
	["list"] = "rbxassetid://6031095372",
	["grid"] = "rbxassetid://6031094791",
	["menu"] = "rbxassetid://6031095387",
	["dots-three"] = "rbxassetid://6031094741",
	["dots-three-vertical"] = "rbxassetid://6031094748",
	["trash"] = "rbxassetid://6031095151",
	["pencil"] = "rbxassetid://6031094451",
	["eye"] = "rbxassetid://6031094768",
	["eye-slash"] = "rbxassetid://6031094780",
	["lock"] = "rbxassetid://6031095423",
	["lock-open"] = "rbxassetid://6031095430",
	["warning"] = "rbxassetid://6031095187",
	["info"] = "rbxassetid://6031094837",
	["question"] = "rbxassetid://6031095042",
	["lightning"] = "rbxassetid://6031095354",
	["fire"] = "rbxassetid://6031094785",
	["rocket"] = "rbxassetid://6031095057",
	["shield"] = "rbxassetid://6031095080",
	["bug"] = "rbxassetid://6031094631",
	["code"] = "rbxassetid://6031094713",
	["terminal"] = "rbxassetid://6031095137",
	["folder"] = "rbxassetid://6031094799",
	["file"] = "rbxassetid://6031094754",
	["image"] = "rbxassetid://6031094819",
	["video"] = "rbxassetid://6031095176",
	["music"] = "rbxassetid://6031095438",
	["microphone"] = "rbxassetid://6031095402",
	["speaker"] = "rbxassetid://6031095111",
	["camera"] = "rbxassetid://6031094642",
	["map-pin"] = "rbxassetid://6031095343",
	["globe"] = "rbxassetid://6031094807",
	["link"] = "rbxassetid://6031095350",
	["calendar"] = "rbxassetid://6031094636",
	["clock"] = "rbxassetid://6031094699",
	["chart-bar"] = "rbxassetid://6031094674",
	["currency-dollar"] = "rbxassetid://6031094724",
	["shopping-cart"] = "rbxassetid://6031095097",
	["ticket"] = "rbxassetid://6031095145",
	["bookmarks"] = "rbxassetid://6031094618",
	["book-open"] = "rbxassetid://6031094610",
	["puzzle-piece"] = "rbxassetid://6031095031",
	["game-controller"] = "rbxassetid://6031094848",
	["cube"] = "rbxassetid://6031094731",
	["database"] = "rbxassetid://6031094735",
	["cloud"] = "rbxassetid://6031094720",
	["wifi-high"] = "rbxassetid://6031095193",
	["devices"] = "rbxassetid://6031094704",
	["monitor"] = "rbxassetid://6031095409",
	["print"] = "rbxassetid://6031095016",
	["scissors"] = "rbxassetid://6031095072",
	["copy"] = "rbxassetid://6031094725",
	["clipboard-text"] = "rbxassetid://6031094695",
	["keyboard"] = "rbxassetid://6031094856",
	["mouse"] = "rbxassetid://6031095416",
	["download"] = "rbxassetid://6031094760",
	["upload"] = "rbxassetid://6031095168",
	["gear-six"] = "rbxassetid://6031094950",
	["sliders"] = "rbxassetid://6031095090",
	["palette"] = "rbxassetid://6031094441",
	["swatches"] = "rbxassetid://6031095127",
	["text-aa"] = "rbxassetid://6031095158",
	["text-t"] = "rbxassetid://6031095165",
	["text-b"] = "rbxassetid://6031094674",
	["text-italic"] = "rbxassetid://6031095163",
	["text-underline"] = "rbxassetid://6031095174",
	["text-strikethrough"] = "rbxassetid://6031095160",
	["list-bullets"] = "rbxassetid://6031095329",
	["list-numbers"] = "rbxassetid://6031095346",
	["indent"] = "rbxassetid://6031094861",
	["outdent"] = "rbxassetid://6031095444",
	["text-align-left"] = "rbxassetid://6031095448",
	["text-align-center"] = "rbxassetid://6031095449",
	["text-align-right"] = "rbxassetid://6031095450",
	["text-align-justify"] = "rbxassetid://6031095451",
	["sign-out"] = "rbxassetid://6031095084",
	["sign-in"] = "rbxassetid://6031095079",
	["user-plus"] = "rbxassetid://6031095216",
	["users"] = "rbxassetid://6031095205",
	["user-circle"] = "rbxassetid://6031095203",
	["identification"] = "rbxassetid://6031094853",
	["identification-card"] = "rbxassetid://6031094854",
	["phone"] = "rbxassetid://6031094479",
	["envelope"] = "rbxassetid://6031094768",
	["chats-circle"] = "rbxassetid://6031094684",
	["chat-dots"] = "rbxassetid://6031094677",
	["paper-plane"] = "rbxassetid://6031095441",
	["bell-ringing"] = "rbxassetid://6031094574",
	["bell-simple"] = "rbxassetid://6031094568",
	["bell-slash"] = "rbxassetid://6031094581",
	["magnifying-glass"] = "rbxassetid://6031095336",
	["funnel"] = "rbxassetid://6031094843",
	["slider"] = "rbxassetid://6031095102",
	["toggle-left"] = "rbxassetid://6031095155",
	["toggle-right"] = "rbxassetid://6031095159",
	["check-circle"] = "rbxassetid://6031094680",
	["x-circle"] = "rbxassetid://6031095210",
	["warning-circle"] = "rbxassetid://6031095190",
	["info"] = "rbxassetid://6031094839",
	["question"] = "rbxassetid://6031095046",
	["exclamation"] = "rbxassetid://6031094776",
}

-- Material Design icons
local MaterialIcons = {
	["home"] = "rbxassetid://6031094674",
	["settings"] = "rbxassetid://6031094942",
	["person"] = "rbxassetid://6031095023",
	["notifications"] = "rbxassetid://6031094768",
	["favorite"] = "rbxassetid://6031094828",
	["star"] = "rbxassetid://6031095142",
	["search"] = "rbxassetid://6031095066",
	["add"] = "rbxassetid://6031094589",
	["remove"] = "rbxassetid://6031094422",
	["close"] = "rbxassetid://6031095199",
	["check"] = "rbxassetid://6031094691",
	["arrow-forward"] = "rbxassetid://6031094540",
	["arrow-back"] = "rbxassetid://6031094527",
	["arrow-upward"] = "rbxassetid://6031094552",
	["arrow-downward"] = "rbxassetid://6031094514",
	["expand-more"] = "rbxassetid://6031094659",
	["expand-less"] = "rbxassetid://6031094664",
	["chevron-right"] = "rbxassetid://6031094654",
	["chevron-left"] = "rbxassetid://6031094648",
	["menu"] = "rbxassetid://6031095387",
	["more-vert"] = "rbxassetid://6031094748",
	["more-horiz"] = "rbxassetid://6031094741",
	["delete"] = "rbxassetid://6031095151",
	["edit"] = "rbxassetid://6031094451",
	["visibility"] = "rbxassetid://6031094768",
	["visibility-off"] = "rbxassetid://6031094780",
	["lock"] = "rbxassetid://6031095423",
	["lock-open"] = "rbxassetid://6031095430",
	["warning"] = "rbxassetid://6031095187",
	["info"] = "rbxassetid://6031094837",
	["help"] = "rbxassetid://6031095042",
	["error"] = "rbxassetid://6031094776",
	["bolt"] = "rbxassetid://6031095354",
	["local-fire-department"] = "rbxassetid://6031094785",
	["rocket-launch"] = "rbxassetid://6031095057",
	["security"] = "rbxassetid://6031095080",
	["bug-report"] = "rbxassetid://6031094631",
	["code"] = "rbxassetid://6031094713",
	["terminal"] = "rbxassetid://6031095137",
	["folder"] = "rbxassetid://6031094799",
	["description"] = "rbxassetid://6031094754",
	["image"] = "rbxassetid://6031094819",
	["videocam"] = "rbxassetid://6031095176",
	["music-note"] = "rbxassetid://6031095438",
	["mic"] = "rbxassetid://6031095402",
	["volume-up"] = "rbxassetid://6031095111",
	["camera-alt"] = "rbxassetid://6031094642",
	["place"] = "rbxassetid://6031095343",
	["public"] = "rbxassetid://6031094807",
	["link"] = "rbxassetid://6031095350",
	["calendar-today"] = "rbxassetid://6031094636",
	["schedule"] = "rbxassetid://6031094699",
	["bar-chart"] = "rbxassetid://6031094674",
	["attach-money"] = "rbxassetid://6031094724",
	["shopping-cart"] = "rbxassetid://6031095097",
	["confirmation-number"] = "rbxassetid://6031095145",
	["bookmark"] = "rbxassetid://6031094618",
	["menu-book"] = "rbxassetid://6031094610",
	["extension"] = "rbxassetid://6031095031",
	["sports-esports"] = "rbxassetid://6031094848",
	["view-in-ar"] = "rbxassetid://6031094731",
	["storage"] = "rbxassetid://6031094735",
	["cloud"] = "rbxassetid://6031094720",
	["wifi"] = "rbxassetid://6031095193",
	["devices"] = "rbxassetid://6031094704",
	["computer"] = "rbxassetid://6031095409",
	["print"] = "rbxassetid://6031095016",
	["content-cut"] = "rbxassetid://6031095072",
	["content-copy"] = "rbxassetid://6031094725",
	["content-paste"] = "rbxassetid://6031094695",
	["keyboard"] = "rbxassetid://6031094856",
	["mouse"] = "rbxassetid://6031095416",
	["download"] = "rbxassetid://6031094760",
	["upload"] = "rbxassetid://6031095168",
	["tune"] = "rbxassetid://6031094950",
	["tune"] = "rbxassetid://6031095090",
	["palette"] = "rbxassetid://6031094441",
	["gradient"] = "rbxassetid://6031095127",
	["format-color-text"] = "rbxassetid://6031095158",
	["format-bold"] = "rbxassetid://6031094674",
	["format-italic"] = "rbxassetid://6031095163",
	["format-underlined"] = "rbxassetid://6031095174",
	["format-strikethrough"] = "rbxassetid://6031095160",
	["format-list-bulleted"] = "rbxassetid://6031095329",
	["format-list-numbered"] = "rbxassetid://6031095346",
	["format-indent-increase"] = "rbxassetid://6031094861",
	["format-indent-decrease"] = "rbxassetid://6031095444",
	["format-align-left"] = "rbxassetid://6031095448",
	["format-align-center"] = "rbxassetid://6031095449",
	["format-align-right"] = "rbxassetid://6031095450",
	["format-align-justify"] = "rbxassetid://6031095451",
	["logout"] = "rbxassetid://6031095084",
	["login"] = "rbxassetid://6031095079",
	["person-add"] = "rbxassetid://6031095216",
	["people"] = "rbxassetid://6031095205",
	["account-circle"] = "rbxassetid://6031095203",
	["badge"] = "rbxassetid://6031094853",
	["credit-card"] = "rbxassetid://6031094854",
	["phone"] = "rbxassetid://6031094479",
	["email"] = "rbxassetid://6031094768",
	["chat"] = "rbxassetid://6031094684",
	["comment"] = "rbxassetid://6031094677",
	["send"] = "rbxassetid://6031095441",
	["notifications-active"] = "rbxassetid://6031094574",
	["notifications-none"] = "rbxassetid://6031094568",
	["notifications-off"] = "rbxassetid://6031094581",
	["search"] = "rbxassetid://6031095336",
	["filter-list"] = "rbxassetid://6031094843",
	["tune"] = "rbxassetid://6031095102",
	["toggle-on"] = "rbxassetid://6031095159",
	["toggle-off"] = "rbxassetid://6031095155",
	["check-circle"] = "rbxassetid://6031094680",
	["cancel"] = "rbxassetid://6031095210",
	["warning"] = "rbxassetid://6031095190",
	["info"] = "rbxassetid://6031094839",
	["help"] = "rbxassetid://6031095046",
	["error"] = "rbxassetid://6031094776",
}

-- Custom icon presets
local CustomIcons = {}

-- Register a custom icon
function Icons.Register(name: string, assetId: string, weight: string?)
	local weight = weight or "Regular"
	Icons.Registry[name] = {
		AssetId = assetId,
		Weight = weight,
	}
	return Icons
end

-- Register multiple icons at once
function Icons.RegisterBatch(icons: table, weight: string?)
	for name, assetId in pairs(icons) do
		Icons.Register(name, assetId, weight)
	end
	return Icons
end

-- Load a preset icon set
function Icons.LoadPreset(presetName: string)
	if presetName == "Phosphor" then
		Icons.LoadedPresets.PhosphorRegular = PhosphorRegular
		Icons.LoadedPresets.PhosphorFilled = PhosphorFilled
		Icons.ActivePreset = "Phosphor"
	elseif presetName == "Material" then
		Icons.LoadedPresets.Material = MaterialIcons
		Icons.ActivePreset = "Material"
	elseif presetName == "Custom" then
		Icons.ActivePreset = "Custom"
	end

	return Icons
end

-- Get icon asset ID by name
function Icons.Get(name: string, weight: string?): string?
	weight = weight or "Regular"

	if Icons.ActivePreset == "Phosphor" then
		if weight == "Filled" then
			return PhosphorFilled[name]
		else
			return PhosphorRegular[name]
		end
	elseif Icons.ActivePreset == "Material" then
		return MaterialIcons[name]
	elseif Icons.ActivePreset == "Custom" then
		return Icons.Registry[name] and Icons.Registry[name].AssetId
	end

	return nil
end

-- Create an icon ImageLabel
function Icons.Create(
	name: string,
	parent: Instance?,
	size: UDim2?,
	position: UDim2?,
	color: Color3?,
	transparency: number?,
	weight: string?
): ImageLabel
	local assetId = Icons.Get(name, weight)
	if not assetId then
		warn(("Icon \"" .. tostring(name) .. "\" not found in preset " .. tostring(Icons.ActivePreset)))
		return nil
	end

	local image = Instance.new("ImageLabel")
	image.Name = name
	image.Size = size or UDim2.new(0, 24, 0, 24)
	image.Position = position or UDim2.new(0, 0, 0, 0)
	image.BackgroundTransparency = 1
	image.Image = assetId
	image.ImageColor3 = color or Color3.new(1, 1, 1)
	image.ImageTransparency = transparency or 0

	if parent then
		image.Parent = parent
	end

	return image
end

-- Create icon in a circular pill background
function Icons.CreatePill(
	name: string,
	parent: Instance?,
	size: number?,
	color: Color3?,
	transparency: number?,
	weight: string?
): Frame
	local pillSize = size or 22

	local pill = Instance.new("Frame")
	pill.Name = (tostring(name) .. "Pill")
	pill.Size = UDim2.new(0, pillSize, 0, pillSize)
	pill.BackgroundColor3 = color or Color3.fromHex("#7c3aed")
	pill.BackgroundTransparency = transparency or 0.85

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = pill

	-- Center icon in pill
	local icon = Icons.Create(
		name,
		pill,
		UDim2.new(0, pillSize - 6, 0, pillSize - 6),
		UDim2.new(0.5, -(pillSize - 6) / 2, 0.5, -(pillSize - 6) / 2),
		Color3.new(1, 1, 1),
		0,
		weight
	)

	if parent then
		pill.Parent = parent
	end

	return pill
end

-- Check if icon exists
function Icons.Exists(name: string, weight: string?): boolean
	return Icons.Get(name, weight) ~= nil
end

-- Get all available icon names for current preset
function Icons.GetAvailable(): {string}
	if Icons.ActivePreset == "Phosphor" then
		local regularKeys = {}
		for key, _ in pairs(PhosphorRegular) do
			table.insert(regularKeys, key)
		end
		return regularKeys
	elseif Icons.ActivePreset == "Material" then
		local materialKeys = {}
		for key, _ in pairs(MaterialIcons) do
			table.insert(materialKeys, key)
		end
		return materialKeys
	elseif Icons.ActivePreset == "Custom" then
		local customKeys = {}
		for key, _ in pairs(Icons.Registry) do
			table.insert(customKeys, key)
		end
		return customKeys
	end
	return {}
end

-- Initialize default preset
Icons.LoadPreset("Phosphor")

return Icons