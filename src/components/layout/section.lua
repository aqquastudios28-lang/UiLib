-- QwenUILib Section Component
-- Collapsible sections with layout grouping

local Section = {}
Section.__index = Section

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)
local Icons = require(script.Parent.Parent.Icons)

-- Create a new section
function Section.Create(config: table)
	config = config or {}
	local title = config.Title or "Section"
	local parent = config.Parent
	local collapsed = config.Collapsed or false

	if not parent then
		error("Section requires a parent frame")
	end

	-- Main section container
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Name = ("Section_" .. tostring(title))
	sectionFrame.Size = UDim2.new(1, 0, 0, 0)
	sectionFrame.BackgroundTransparency = 1
	sectionFrame.ZIndex = 2

	-- Section header (clickable)
	local header = Instance.new("TextButton")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 32)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.BackgroundColor3 = Theme.Colors.BackgroundTertiary
	header.BackgroundTransparency = Theme.Transparency.BackgroundTertiary
	header.ZIndex = 2

	local headerCorner = Utils.CreateCorner(Theme.CornerRadius.Button, header)
	local headerStroke = Utils.CreateStroke(header, Theme.Colors.BorderPrimary, 1, Theme.Transparency.Border)

	header.Parent = sectionFrame

	-- Title text
	local titleText = Instance.new("TextLabel")
	titleText.Name = "Title"
	titleText.Size = UDim2.new(1, -40, 1, 0)
	titleText.Position = UDim2.new(0, 12, 0, 0)
	titleText.BackgroundTransparency = 1
	titleText.Text = title
	titleText.TextColor3 = Theme.Colors.TextPrimary
	titleText.TextSize = Theme.Font.Size.Header
	titleText.Font = Theme.Font.Family
	titleText.TextXAlignment = Enum.TextXAlignment.Left
	titleText.TextYAlignment = Enum.TextYAlignment.Center
	titleText.ZIndex = 2

	titleText.Parent = header

	-- Expand/collapse icon
	local expandIcon = Icons.Create(
		collapsed and "caret-right" or "caret-down",
		header,
		UDim2.new(0, 20, 0, 20),
		UDim2.new(1, -28, 0.5, -10),
		Theme.Colors.TextSecondary,
		0.8
	)

	-- Content container
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "Content"
	contentFrame.Size = UDim2.new(1, 0, 0, 0)
	contentFrame.Position = UDim2.new(0, 0, 0, 36)
	contentFrame.BackgroundTransparency = 1
	contentFrame.ZIndex = 1

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.FillDirection = Enum.FillDirection.Vertical
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	contentLayout.Padding = UDim.new(0, Theme.Spacing.SM)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Parent = contentFrame

	local contentPadding = Utils.CreatePadding(contentFrame, Theme.Spacing.SM, Theme.Spacing.SM, Theme.Spacing.SM, Theme.Spacing.SM)

	contentFrame.Parent = sectionFrame

	-- Auto-size so the section grows/shrinks to fit its children (and its
	-- collapsed state) without any manual AbsoluteContentSize math.
	Utils.SafeAutoSize(contentFrame, "Y")
	Utils.SafeAutoSize(sectionFrame, "Y")

	-- Section state
	local sectionState = {
		Frame = sectionFrame,
		Header = header,
		TitleText = titleText,
		Content = contentFrame,
		ContentLayout = contentLayout,
		ExpandIcon = expandIcon,
		IsCollapsed = collapsed,
		Title = title,
	}

	-- Toggle collapse
	header.MouseButton1Click:Connect(function()
		sectionState:Toggle()
	end)

	-- Initial collapsed state (section auto-sizes; hiding content shrinks it)
	if collapsed then
		contentFrame.Visible = false
	end

	-- Section methods
	function sectionState:Toggle()
		sectionState.IsCollapsed = not sectionState.IsCollapsed

		if sectionState.IsCollapsed then
			-- Collapse: hide content; AutomaticSize shrinks the section to the header
			expandIcon.Image = Icons.Get("caret-right", "Regular")
			contentFrame.Visible = false
		else
			-- Expand: show content; AutomaticSize grows the section to fit it
			expandIcon.Image = Icons.Get("caret-down", "Regular")
			contentFrame.Visible = true

			Utils.Tween(header, {
				BackgroundColor3 = Theme.Colors.BackgroundHover,
			}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			task.delay(0.15, function()
				Utils.Tween(header, {
					BackgroundColor3 = Theme.Colors.BackgroundTertiary,
				}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			end)
		end
	end

	function sectionState:SetTitle(newTitle: string)
		sectionState.Title = newTitle
		sectionState.TitleText.Text = newTitle
	end

	function sectionState:AddComponent(component)
		-- AutomaticSize keeps the section fitted; no manual resize needed.
		if typeof(component) == "Instance" then
			component.Parent = contentFrame
		end
	end

	function sectionState:Destroy()
		Utils.Tween(sectionFrame, {
			Transparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
		}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

		task.delay(0.2, function()
			sectionFrame:Destroy()
		end)
	end

	-- Parent section
	sectionFrame.Parent = parent

	return sectionState
end

return Section