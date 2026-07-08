-- QwenUILib Image Component
-- Fitted captioned graphics

local Image = {}
Image.__index = Image

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)

-- Create an image
function Image.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local imageId = config.Image or ""
	local caption = config.Caption or ""
	local width = config.Width or UDim2.new(1, 0, 0, 200)
	local aspectRatio = config.AspectRatio or 16/9

	if not parent then
		error("Image requires a parent frame")
	end

	-- Main image container
	local imageFrame = Instance.new("Frame")
	imageFrame.Name = ("Image_" .. tostring(imageId:sub(1, 20)))
	imageFrame.Size = width
	imageFrame.BackgroundTransparency = 1
	imageFrame.ZIndex = 2

	-- Image label (leaves a caption strip at the bottom when captioned)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Image"
	imageLabel.Size = UDim2.new(1, 0, 1, caption ~= "" and -24 or 0)
	imageLabel.Position = UDim2.new(0, 0, 0, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = imageId ~= "" and ("rbxassetid://" .. tostring(imageId)) or ""
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.ZIndex = 2

	imageLabel.Parent = imageFrame

	-- Optional caption
	local captionLabel = nil
	if caption ~= "" then
		captionLabel = Instance.new("TextLabel")
		captionLabel.Name = "Caption"
		captionLabel.Size = UDim2.new(1, 0, 0, 20)
		captionLabel.Position = UDim2.new(0, 0, 1, -20)
		captionLabel.BackgroundTransparency = 1
		captionLabel.Text = caption
		captionLabel.TextColor3 = Theme.Colors.TextMuted
		captionLabel.TextSize = Theme.Font.Size.Small
		captionLabel.Font = Theme.Font.Family
		captionLabel.TextXAlignment = Enum.TextXAlignment.Center
		captionLabel.TextYAlignment = Enum.TextYAlignment.Top
		captionLabel.ZIndex = 2

		captionLabel.Parent = imageFrame
	end

	-- Image state
	local imageState = {
		Frame = imageFrame,
		ImageLabel = imageLabel,
		CaptionLabel = captionLabel,
	}

	-- Image methods
	function imageState:SetImage(newImageId: string)
		imageState.ImageLabel.Image = newImageId ~= "" and ("rbxassetid://" .. tostring(newImageId)) or ""
	end

	function imageState:SetCaption(newCaption: string)
		if newCaption == "" then
			if imageState.CaptionLabel then
				imageState.CaptionLabel:Destroy()
				imageState.CaptionLabel = nil
			end
		else
			if not imageState.CaptionLabel then
				local caption = Instance.new("TextLabel")
				caption.Name = "Caption"
				caption.Size = UDim2.new(1, 0, 0, 20)
				caption.Position = UDim2.new(0, 0, 1, -20)
				caption.BackgroundTransparency = 1
				caption.Text = newCaption
				caption.TextColor3 = Theme.Colors.TextMuted
				caption.TextSize = Theme.Font.Size.Small
				caption.Font = Theme.Font.Family
				caption.TextXAlignment = Enum.TextXAlignment.Center
				caption.TextYAlignment = Enum.TextYAlignment.Top
				caption.ZIndex = 2

				caption.Parent = imageFrame
				imageState.CaptionLabel = caption
			else
				imageState.CaptionLabel.Text = newCaption
			end
		end
	end

	function imageState:Destroy()
		imageFrame:Destroy()
	end

	-- Parent image
	imageFrame.Parent = parent

	return imageState
end

return Image