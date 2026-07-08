-- QwenUILib Banner Component
-- Cropped background image headers

local Banner = {}
Banner.__index = Banner

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)

-- Create a banner
function Banner.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local title = config.Title or "Banner"
	local subtitle = config.Subtitle or ""
	local imageId = config.Image or ""
	local height = config.Height or 120

	if not parent then
		error("Banner requires a parent frame")
	end

	-- Main banner container
	local bannerFrame = Instance.new("Frame")
	bannerFrame.Name = ("Banner_" .. tostring(title))
	bannerFrame.Size = UDim2.new(1, 0, 0, height)
	bannerFrame.BackgroundTransparency = 1
	bannerFrame.ZIndex = 2

	-- Background image (cropped)
	local backgroundImage = Instance.new("ImageLabel")
	backgroundImage.Name = "Background"
	backgroundImage.Size = UDim2.new(1, 0, 1, 0)
	backgroundImage.Position = UDim2.new(0, 0, 0, 0)
	backgroundImage.BackgroundTransparency = 1
	backgroundImage.Image = imageId ~= "" and ("rbxassetid://" .. tostring(imageId)) or ""
	backgroundImage.ScaleType = Enum.ScaleType.Crop
	backgroundImage.ZIndex = 1

	backgroundImage.Parent = bannerFrame

	-- Dark overlay for text readability
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Position = UDim2.new(0, 0, 0, 0)
	overlay.BackgroundColor3 = Color3.fromHex("#000000")
	overlay.BackgroundTransparency = 0.4
	overlay.ZIndex = 2

	overlay.Parent = bannerFrame

	-- Inner glass bezel
	local innerFrame = Instance.new("Frame")
	innerFrame.Name = "Inner"
	innerFrame.Size = UDim2.new(1, -6, 1, -6)
	innerFrame.Position = UDim2.new(0, 3, 0, 3)
	innerFrame.BackgroundTransparency = 1
	innerFrame.ZIndex = 2

	local innerCorner = Utils.CreateCorner(7, innerFrame)
	innerFrame.Parent = bannerFrame

	-- Title text (centered as a pair with the subtitle, with clear spacing)
	local titleText = Instance.new("TextLabel")
	titleText.Name = "Title"
	titleText.Size = UDim2.new(1, -24, 0, 22)
	titleText.Position = UDim2.new(0, 12, 0.5, subtitle ~= "" and -22 or -11)
	titleText.BackgroundTransparency = 1
	titleText.Text = title
	titleText.TextColor3 = Theme.Colors.TextPrimary
	titleText.TextSize = Theme.Font.Size.Header
	titleText.Font = Theme.Font.Family
	titleText.TextXAlignment = Enum.TextXAlignment.Left
	titleText.TextYAlignment = Enum.TextYAlignment.Center
	titleText.ZIndex = 3

	titleText.Parent = innerFrame

	-- Subtitle text
	if subtitle ~= "" then
		local subtitleText = Instance.new("TextLabel")
		subtitleText.Name = "Subtitle"
		subtitleText.Size = UDim2.new(1, -24, 0, 18)
		subtitleText.Position = UDim2.new(0, 12, 0.5, 2)
		subtitleText.BackgroundTransparency = 1
		subtitleText.Text = subtitle
		subtitleText.TextColor3 = Theme.Colors.TextSecondary
		subtitleText.TextSize = Theme.Font.Size.Body
		subtitleText.Font = Theme.Font.Family
		subtitleText.TextXAlignment = Enum.TextXAlignment.Left
		subtitleText.TextYAlignment = Enum.TextYAlignment.Center
		subtitleText.ZIndex = 3

		subtitleText.Parent = innerFrame
	end

	-- Parent banner
	bannerFrame.Parent = parent

	local bannerState = {
		Frame = bannerFrame,
		BackgroundImage = backgroundImage,
		Overlay = overlay,
		TitleText = titleText,
		SubtitleText = subtitle ~= "" and innerFrame:FindFirstChild("Subtitle") or nil,
	}

	-- Methods
	function bannerState:SetTitle(newTitle: string)
		bannerState.TitleText.Text = newTitle
	end

	function bannerState:SetSubtitle(newSubtitle: string)
		if newSubtitle == "" then
			if bannerState.SubtitleText then
				bannerState.SubtitleText:Destroy()
				bannerState.SubtitleText = nil
				titleText.Position = UDim2.new(0, 12, 0.5, -11)
			end
		else
			if not bannerState.SubtitleText then
				local subtitleText = Instance.new("TextLabel")
				subtitleText.Name = "Subtitle"
				subtitleText.Size = UDim2.new(1, -24, 0, 18)
				subtitleText.Position = UDim2.new(0, 12, 0.5, 2)
				subtitleText.BackgroundTransparency = 1
				subtitleText.Text = newSubtitle
				subtitleText.TextColor3 = Theme.Colors.TextSecondary
				subtitleText.TextSize = Theme.Font.Size.Body
				subtitleText.Font = Theme.Font.Family
				subtitleText.TextXAlignment = Enum.TextXAlignment.Left
				subtitleText.TextYAlignment = Enum.TextYAlignment.Center
				subtitleText.ZIndex = 3

				subtitleText.Parent = innerFrame
				bannerState.SubtitleText = subtitleText
				titleText.Position = UDim2.new(0, 12, 0.5, -22)
			else
				bannerState.SubtitleText.Text = newSubtitle
			end
		end
	end

	function bannerState:SetImage(imageId: string)
		bannerState.BackgroundImage.Image = imageId ~= "" and ("rbxassetid://" .. tostring(imageId)) or ""
	end

	function bannerState:Destroy()
		local function fadeOut()
			Utils.Tween(bannerFrame, {
				Transparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
			}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		end

		fadeOut()
		task.delay(0.25, function()
			bannerFrame:Destroy()
		end)
	end

	return bannerState
end

return Banner