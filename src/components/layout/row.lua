-- QwenUILib Row Component
-- Horizontal layouts dividing space evenly while preserving widget height

local Row = {}
Row.__index = Row

local Theme = require(script.Parent.Parent.Theme)
local Utils = require(script.Parent.Parent.Utils)

-- Create a new horizontal row
function Row.Create(config: table)
	config = config or {}
	local parent = config.Parent
	local gap = config.Gap or Theme.Spacing.SM
	local items = config.Items or {}

	if not parent then
		error("Row requires a parent frame")
	end

	-- Main row container
	local rowFrame = Instance.new("Frame")
	rowFrame.Name = "Row"
	rowFrame.Size = UDim2.new(1, 0, 0, 0)
	rowFrame.BackgroundTransparency = 1
	rowFrame.ZIndex = 2

	-- Horizontal layout
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, gap)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = rowFrame

	-- Grow to the height of the tallest item.
	Utils.SafeAutoSize(rowFrame, "Y")

	-- Row state
	local rowState = {
		Frame = rowFrame,
		Layout = layout,
		Gap = gap,
		Items = {},
	}

	-- Add items to row
	for i, item in ipairs(items) do
		if typeof(item) == "Instance" then
			item.LayoutOrder = i
			item.Parent = rowFrame
			table.insert(rowState.Items, item)
		end
	end

	-- Row methods
	function rowState:AddItem(item: Instance)
		if typeof(item) == "Instance" then
			item.LayoutOrder = #self.Items + 1
			item.Parent = self.Frame
			table.insert(self.Items, item)
		end
		return self
	end

	function rowState:RemoveItem(item: Instance)
		for i, existingItem in ipairs(self.Items) do
			if existingItem == item then
				table.remove(self.Items, i)
				item:Destroy()
				break
			end
		end
		return self
	end

	function rowState:Clear()
		for _, item in ipairs(self.Items) do
			if item and item.Parent then
				item:Destroy()
			end
		end
		table.clear(self.Items)
		return self
	end

	-- Parent row (height is handled by SafeAutoSize above)
	rowFrame.Parent = parent

	return rowState
end

return Row