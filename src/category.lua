return function(UILibrary)
    local Utils = require(script.Parent.utils)
    local objectGenerator = require(script.Parent.objectGenerator)
    local EffectLib = require(script.Parent.effects)(UILibrary)

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local TweenService = game:GetService("TweenService")

function UILibrary.Category:Button(name, icon)
local contentholder = self.ContentHolder
local button = objectGenerator.new("CategoryButton")

button.InnerContent.Image.Image = icon
button.InnerContent.Title.Text = name

button.Parent = self.contentHolder.Bar2Holder
button.LayoutOrder = Utils.getLayoutOrder(self.contentHolder.Bar2Holder)
button.Name = name

local totalCount = 0

for i, v in pairs(self.contentHolder.Bar2Holder:GetChildren()) do
    if v:IsA("GuiObject") then
        totalCount = totalCount + 1
    end
end

for i, v in pairs(self.contentHolder.Bar2Holder:GetChildren()) do
    if v:IsA("GuiObject") then
        v.Size = UDim2.fromScale(1, 1 / totalCount)
    end
end

button.Size = UDim2.fromScale(1, 1 / totalCount)

self.oldSelf.UI[self.categoryUI.Name][name] = {}

local CategoryFrame = objectGenerator.new("CategoryFrame")
CategoryFrame.Name = name
CategoryFrame.Parent = self.oldSelf.MainUI.MainUI.Content
CategoryFrame.Visible = true

local Hover =
    EffectLib.ButtonHoverEffect(
    button,
    function()
        if self.currentCategorySelection ~= button then
            return true
        else
            return false
        end
    end
)
local Click = EffectLib.ButtonClickEffect(button)

Click.Event:Connect(
    function()
        Utils.CircleClick(button, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)

        if self.oldSelf.currentSelection.Name == self.categoryUI.Name then
            self.oldSelf:ChangeCategorySelection(name)
        end
    end
)

if self.oldSelf.currentCategorySelection == nil and self.oldSelf.currentSelection.Name == self.categoryUI.Name then
    self.oldSelf:ChangeCategorySelection(name)
end

return setmetatable(
    {
        Effects = {
            Hover = Hover,
            Click = Click
        },
        oldSelf = self,
        CategoryName = self.categoryUI.Name,
        SectionName = name,
        CategoryFrame = CategoryFrame
    },
    UILibrary.Button
)
end

end
