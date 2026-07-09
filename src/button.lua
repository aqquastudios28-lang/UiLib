return function(UILibrary)
    local Utils = require(script.Parent.utils)
    local objectGenerator = require(script.Parent.objectGenerator)

function UILibrary.Button:Section(name, side)
local Section = objectGenerator.new("Section")
Section.Border.SectionTitle.Text = name

Section.DropShadow.Size = UDim2.new(1, 25, 1, 25)
Section.Name = name

Section.Border.Content.ChildAdded:Connect(
    function(c)
        local n = 25 + (10 * math.clamp(#Section.Border.Content:GetChildren() - 2, 0, 3))

        Section.DropShadow.Size = UDim2.new(1, n, 1, n)
    end
)

Section.Parent = self.oldSelf.oldSelf.MainUI.MainUI.Content[self.SectionName][side]
Section.LayoutOrder = Utils.getLayoutOrder(self.oldSelf.oldSelf.MainUI.MainUI.Content[self.SectionName][side])

self.oldSelf.oldSelf.UI[self.oldSelf.categoryUI.Name][self.SectionName][name] = {}

Section.Size = UDim2.new(1, 0, 0, Section.Border.Content.UIListLayout.AbsoluteContentSize.Y + 20)

Section.Border.Content.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
    function()
        Section.Size = UDim2.new(1, 0, 0, Section.Border.Content.UIListLayout.AbsoluteContentSize.Y + 20)
    end
)

return setmetatable(
    {
        MainSelf = self.oldSelf.oldSelf,
        oldSelf = self,
        Section = Section
    },
    UILibrary.Section
)
end

end
