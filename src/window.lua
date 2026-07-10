return function(UILibrary)
    local Utils = require(script.Parent.utils)
    local objectGenerator = require(script.Parent.objectGenerator)
    local Draggable = require(script.Parent.draggable)
    local EffectLib = require(script.Parent.effects)(UILibrary)
    local Theme = require(script.Parent.theme)

    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local TweenService = game:GetService("TweenService")

    --// the drag module keeps two UserInputService connections alive at module
    --// scope; register them so Window:Unload can disconnect them
    if Draggable and Draggable.InputBegan then
        UILibrary.trackConnection(Draggable.InputBegan)
    end

    if Draggable and Draggable.InputEnd then
        UILibrary.trackConnection(Draggable.InputEnd)
    end

function UILibrary.new(gameName, userId, rank)
local GUI = Instance.new("ScreenGui")
GUI.Name = HttpService:GenerateGUID(false)
GUI.Parent =
    RunService:IsStudio() == false and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Global

local window = objectGenerator.new("Window")
window.Parent = GUI

--// make UI draggable
-->> LogoHitbox

local Frame = Instance.new("Frame")
Frame.BackgroundTransparency = 1
Frame.Size = UDim2.fromScale(2, 2)

Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Position = UDim2.fromScale(.5, .5)

local AspectRatio = Instance.new("UIAspectRatioConstraint", Frame)
AspectRatio.AspectRatio = 1.2

Frame.Parent = window.MainUI.Sidebar.ContentHolder.Cheats.Logo
Frame.ZIndex = 300

local Drag = Draggable.Drag(window.MainUI, Frame)

--// Customize the GUI
window.Watermark.Text = ("hydrahub v2 | %s | %s"):format(userId, gameName)
local userinfo = window.MainUI.Sidebar.ContentHolder.UserInfo.Content
userinfo.Rank.Text = rank
userinfo.Title.Text = userId

local windowObject =
    setmetatable(
    {
        UI = {},
        windowInfo = {
            gameName = gameName,
            userId = userId,
            rank = rank
        },
        currentSelection = nil,
        currentCategorySelection = nil,
        currentTab = nil,
        MainUI = window,
        ScreenGui = GUI,
        Drag = Drag,
        unloaded = false
    },
    UILibrary.Window
)

--// Unload button (top right corner)
local UnloadButton = window.MainUI.Unload

UnloadButton.MouseEnter:Connect(
    function()
        TweenService:Create(
            UnloadButton,
            UILibrary.TweenInfo,
            {
                BackgroundColor3 = Color3.fromRGB(160, 62, 72),
                BackgroundTransparency = 0
            }
        ):Play()

        TweenService:Create(
            UnloadButton.Icon,
            UILibrary.TweenInfo,
            {
                ImageColor3 = Color3.fromRGB(255, 255, 255)
            }
        ):Play()
    end
)

UnloadButton.MouseLeave:Connect(
    function()
        TweenService:Create(
            UnloadButton,
            UILibrary.TweenInfo,
            {
                BackgroundColor3 = Color3.fromRGB(28, 29, 38),
                BackgroundTransparency = 0.15
            }
        ):Play()

        TweenService:Create(
            UnloadButton.Icon,
            UILibrary.TweenInfo,
            {
                ImageColor3 = Color3.fromRGB(150, 155, 172)
            }
        ):Play()
    end
)

UnloadButton.MouseButton1Click:Connect(
    function()
        windowObject:Unload()
    end
)

return windowObject
end

function UILibrary.Window:Unload()
if self.unloaded then
    return
end

self.unloaded = true

--// stop every service-level connection (keybinds, slider render loops, ...)
for i, v in pairs(UILibrary._connections) do
    pcall(
        function()
            v:Disconnect()
        end
    )
end

UILibrary._connections = {}

--// stop the window drag handler
if self.Drag then
    pcall(
        function()
            self.Drag:Destroy()
        end
    )
end

--// closing animation, then destroy the whole ScreenGui
local gui = self.ScreenGui

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = self.MainUI.MainUI

TweenService:Create(
    scale,
    TweenInfo.new(.35, Enum.EasingStyle.Back, Enum.EasingDirection.In),
    {
        Scale = 0
    }
):Play()

TweenService:Create(
    self.MainUI.Watermark,
    TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    {
        TextTransparency = 1,
        TextStrokeTransparency = 1
    }
):Play()

task.delay(
    .4,
    function()
        if gui then
            gui:Destroy()
        end
    end
)
end

function UILibrary.Window:setAnimSpeed(val)
val = math.max(tonumber(val) or 100, 1)

UILibrary.TweenInfo = TweenInfo.new(.4 / (val / 100), Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
end

--// Reconfigure the notification container into a bottom-right toast stack.
--// Idempotent: safe to call on every notification.
local function prepareToastContainer(ui)
    ui.AnchorPoint = Vector2.new(1, 1)
    ui.Position = UDim2.new(1, -6, 1, -6)
    ui.Size = UDim2.new(0, 312, 1, -12)
    ui.ClipsDescendants = false

    local layout = ui:FindFirstChildOfClass("UIListLayout")
    if not layout then
        layout = Instance.new("UIListLayout")
        layout.Parent = ui
    end
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
end

function UILibrary.Window:Notification(sett)
local ui = self.MainUI.Notifications
prepareToastContainer(ui)

local W = 300

--// wrapper occupies the layout slot; the card slides within it
local wrapper = Instance.new("Frame")
wrapper.Name = "Toast"
wrapper.BackgroundTransparency = 1
wrapper.BorderSizePixel = 0
wrapper.Size = UDim2.new(0, W, 0, 64)
wrapper.ClipsDescendants = false
wrapper.LayoutOrder = Utils.getLayoutOrder(ui)
wrapper.Parent = ui

local card = Instance.new("Frame")
card.Name = "Card"
card.BackgroundColor3 = Theme.Color.WindowBase
card.BackgroundTransparency = Theme.Alpha.PanelGlass
card.BorderSizePixel = 0
card.AnchorPoint = Vector2.new(0, 0)
card.Position = UDim2.new(1.2, 0, 0, 0)
card.Size = UDim2.new(1, 0, 1, 0)
card.ClipsDescendants = false
card.ZIndex = 60
card.Parent = wrapper
Theme.corner(card, Theme.Radius.Panel)
Theme.stroke(card, Theme.Color.Stroke, Theme.Alpha.Hairline, 1)
Theme.shadow(card, 42, Theme.Alpha.Shadow)
Theme.sheen(card, 0.5)

--// left accent bar
local accent = Instance.new("Frame")
accent.Name = "Accent"
accent.BackgroundColor3 = Theme.Color.Accent
accent.BorderSizePixel = 0
accent.Position = UDim2.new(0, 10, 0.5, 0)
accent.AnchorPoint = Vector2.new(0, 0.5)
accent.Size = UDim2.new(0, 3, 1, -22)
accent.ZIndex = 63
accent.Parent = card
Theme.corner(accent, UDim.new(1, 0))
Theme.accentGradient(accent, 90)
Theme.glow(accent, Theme.Color.Accent, 16, 0.4)

--// info badge
local badge = Instance.new("Frame")
badge.Name = "Badge"
badge.BackgroundColor3 = Theme.Color.Accent
badge.BackgroundTransparency = 0.84
badge.BorderSizePixel = 0
badge.Position = UDim2.new(0, 20, 0.5, 0)
badge.AnchorPoint = Vector2.new(0, 0.5)
badge.Size = UDim2.new(0, 30, 0, 30)
badge.ZIndex = 63
badge.Parent = card
Theme.corner(badge, UDim.new(0, 9))
Theme.stroke(badge, Theme.Color.Accent, 0.55, 1)

local badgeIcon = Instance.new("TextLabel")
badgeIcon.BackgroundTransparency = 1
badgeIcon.Size = UDim2.new(1, 0, 1, 0)
badgeIcon.Position = UDim2.new(0, 0, 0, -1)
badgeIcon.ZIndex = 64
badgeIcon.Font = Theme.Font.Bold
badgeIcon.Text = "i"
badgeIcon.TextColor3 = Theme.Color.Accent
badgeIcon.TextSize = 16
badgeIcon.Parent = badge

--// text block
local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 60, 0, 12)
title.Size = UDim2.new(1, -90, 0, 16)
title.ZIndex = 63
title.Font = Theme.Font.Bold
title.Text = sett.Title or "Notification"
title.TextColor3 = Theme.Color.Text
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.TextTruncate = Enum.TextTruncate.AtEnd
title.Parent = card

local desc = Instance.new("TextLabel")
desc.Name = "Desc"
desc.BackgroundTransparency = 1
desc.Position = UDim2.new(0, 60, 0, 30)
desc.Size = UDim2.new(1, -76, 0, 24)
desc.ZIndex = 63
desc.Font = Theme.Font.Regular
desc.Text = sett.Desc or ""
desc.TextColor3 = Theme.Color.TextSub
desc.TextSize = 12
desc.TextWrapped = true
desc.TextXAlignment = Enum.TextXAlignment.Left
desc.TextYAlignment = Enum.TextYAlignment.Top
desc.Parent = card

--// close button
local close = Instance.new("ImageButton")
close.Name = "Close"
close.BackgroundTransparency = 1
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -10, 0, 10)
close.Size = UDim2.new(0, 16, 0, 16)
close.ZIndex = 64
close.Image = "rbxassetid://7072725342"
close.ImageColor3 = Theme.Color.TextMuted
close.ScaleType = Enum.ScaleType.Fit
close.Parent = card

--// auto-expire progress bar
local bar
if sett.expire then
    bar = Instance.new("Frame")
    bar.Name = "Progress"
    bar.BackgroundColor3 = Theme.Color.Accent
    bar.BorderSizePixel = 0
    bar.AnchorPoint = Vector2.new(0, 1)
    bar.Position = UDim2.new(0, 0, 1, 0)
    bar.Size = UDim2.new(1, 0, 0, 2)
    bar.ZIndex = 64
    bar.Parent = card
    Theme.accentGradient(bar, 0)
end

--// intro
wait(.02)
TweenService:Create(card, Theme.Tween.Back, { Position = UDim2.new(0, 0, 0, 0) }):Play()

local connections = {}
local isOpen = true

local function expire()
    if not isOpen then return end
    isOpen = false

    for i, v in pairs(connections) do
        v:Disconnect()
    end

    TweenService:Create(card, Theme.Tween.In, { Position = UDim2.new(1.25, 0, 0, 0) }):Play()

    task.delay(.32, function()
        TweenService:Create(wrapper, Theme.Tween.Base, { Size = UDim2.new(0, W, 0, 0) }):Play()
        task.delay(.4, function()
            wrapper:Destroy()
        end)
    end)
end

if bar then
    TweenService:Create(bar, TweenInfo.new(sett.expire, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()
    task.delay(sett.expire, function()
        expire()
    end)
end

table.insert(connections, close.MouseEnter:Connect(function()
    TweenService:Create(close, Theme.Tween.Quick, { ImageColor3 = Theme.Color.Text }):Play()
end))
table.insert(connections, close.MouseLeave:Connect(function()
    TweenService:Create(close, Theme.Tween.Quick, { ImageColor3 = Theme.Color.TextMuted }):Play()
end))
table.insert(connections, close.MouseButton1Click:Connect(function()
    expire()
end))
end

function UILibrary.Window:Prompt(sett)
local connections = {}
local selection = false
local answered = false
local bindable = Instance.new("BindableEvent")

--// full-screen dim backdrop (also blocks clicks to the UI behind)
local backdrop = Instance.new("TextButton")
backdrop.Name = "PromptBackdrop"
backdrop.AutoButtonColor = false
backdrop.Text = ""
backdrop.BackgroundColor3 = Theme.Color.Black
backdrop.BackgroundTransparency = 1
backdrop.BorderSizePixel = 0
backdrop.Size = UDim2.new(1, 0, 1, 0)
backdrop.ZIndex = 900
backdrop.Parent = self.ScreenGui

--// modal card
local modal = Instance.new("Frame")
modal.Name = "Prompt"
modal.Active = true
modal.AnchorPoint = Vector2.new(0.5, 0.5)
modal.Position = UDim2.new(0.5, 0, 0.5, 0)
modal.Size = UDim2.new(0, 336, 0, 184)
modal.BackgroundColor3 = Theme.Color.WindowBase
modal.BackgroundTransparency = Theme.Alpha.Glass
modal.BorderSizePixel = 0
modal.ZIndex = 902
modal.Parent = backdrop
Theme.corner(modal, UDim.new(0, 14))
Theme.stroke(modal, Theme.Color.Stroke, Theme.Alpha.HairlineHot, 1)
Theme.shadow(modal, 60, 0.35)
Theme.sheen(modal, 0.45)
Theme.glow(modal, Theme.Color.Accent, 90, 0.72)

local scale = Instance.new("UIScale")
scale.Scale = 0.92
scale.Parent = modal

--// top accent line
local topline = Instance.new("Frame")
topline.BackgroundColor3 = Theme.Color.Accent
topline.BorderSizePixel = 0
topline.AnchorPoint = Vector2.new(0.5, 0)
topline.Position = UDim2.new(0.5, 0, 0, 0)
topline.Size = UDim2.new(0.55, 0, 0, 2)
topline.ZIndex = 905
topline.Parent = modal
local tlg = Instance.new("UIGradient")
tlg.Color = ColorSequence.new(Theme.Color.Accent)
tlg.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(1, 1)
})
tlg.Parent = topline

--// icon badge
local badge = Instance.new("Frame")
badge.BackgroundColor3 = Theme.Color.Accent
badge.BackgroundTransparency = 0.84
badge.BorderSizePixel = 0
badge.AnchorPoint = Vector2.new(0.5, 0)
badge.Position = UDim2.new(0.5, 0, 0, 18)
badge.Size = UDim2.new(0, 42, 0, 42)
badge.ZIndex = 904
badge.Parent = modal
Theme.corner(badge, UDim.new(0, 12))
Theme.stroke(badge, Theme.Color.Accent, 0.55, 1)

local badgeIcon = Instance.new("TextLabel")
badgeIcon.BackgroundTransparency = 1
badgeIcon.Size = UDim2.new(1, 0, 1, 0)
badgeIcon.Position = UDim2.new(0, 0, 0, -1)
badgeIcon.ZIndex = 905
badgeIcon.Font = Theme.Font.Bold
badgeIcon.Text = "?"
badgeIcon.TextColor3 = Theme.Color.Accent
badgeIcon.TextSize = 22
badgeIcon.Parent = badge

--// title
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.new(0.5, 0, 0, 68)
title.Size = UDim2.new(1, -32, 0, 20)
title.ZIndex = 904
title.Font = Theme.Font.Bold
title.Text = sett.Title or "Prompt"
title.TextColor3 = Theme.Color.Text
title.TextSize = 16
title.TextTruncate = Enum.TextTruncate.AtEnd
title.Parent = modal

--// description
local desc = Instance.new("TextLabel")
desc.BackgroundTransparency = 1
desc.AnchorPoint = Vector2.new(0.5, 0)
desc.Position = UDim2.new(0.5, 0, 0, 90)
desc.Size = UDim2.new(1, -44, 0, 36)
desc.ZIndex = 904
desc.Font = Theme.Font.Regular
desc.Text = sett.Desc or ""
desc.TextColor3 = Theme.Color.TextSub
desc.TextSize = 13
desc.TextWrapped = true
desc.TextYAlignment = Enum.TextYAlignment.Top
desc.Parent = modal

--// button row
local row = Instance.new("Frame")
row.BackgroundTransparency = 1
row.AnchorPoint = Vector2.new(0.5, 1)
row.Position = UDim2.new(0.5, 0, 1, -16)
row.Size = UDim2.new(1, -32, 0, 38)
row.ZIndex = 904
row.Parent = modal
local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowLayout.Padding = UDim.new(0, 10)
rowLayout.Parent = row

local function makeButton(text, primary, order)
    local btn = Instance.new("TextButton")
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = order
    btn.Size = UDim2.new(0.5, -5, 1, 0)
    btn.BorderSizePixel = 0
    btn.ZIndex = 905
    if primary then
        btn.BackgroundColor3 = Theme.Color.Accent2
        btn.BackgroundTransparency = 0
    else
        btn.BackgroundColor3 = Theme.Color.Card
        btn.BackgroundTransparency = 0
    end
    Theme.corner(btn, Theme.Radius.Card)
    if primary then
        Theme.stroke(btn, Theme.Color.Accent, 0.5, 1)
        Theme.glow(btn, Theme.Color.Accent, 26, 0.6)
    else
        Theme.stroke(btn, Theme.Color.Stroke, Theme.Alpha.Hairline, 1)
    end

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.ZIndex = 906
    lbl.Font = Theme.Font.Semibold
    lbl.Text = text
    lbl.TextColor3 = primary and Theme.Color.White or Theme.Color.TextSub
    lbl.TextSize = 13
    lbl.Parent = btn
    btn.Parent = row
    return btn, lbl
end

local cancelBtn, cancelLbl = makeButton("Cancel", false, 1)
local confirmBtn = makeButton("Confirm", true, 2)

local function close(result)
    if answered then return end
    answered = true
    selection = result

    for i, v in pairs(connections) do v:Disconnect() end

    TweenService:Create(backdrop, Theme.Tween.In, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(scale, Theme.Tween.In, { Scale = 0.9 }):Play()
    TweenService:Create(modal, Theme.Tween.In, { BackgroundTransparency = 1 }):Play()

    task.delay(.28, function()
        backdrop:Destroy()
        bindable:Fire()
    end)
end

--// intro
wait(.02)
TweenService:Create(backdrop, Theme.Tween.Base, { BackgroundTransparency = 0.45 }):Play()
TweenService:Create(scale, Theme.Tween.Back, { Scale = 1 }):Play()

table.insert(connections, confirmBtn.MouseEnter:Connect(function()
    TweenService:Create(confirmBtn, Theme.Tween.Quick, { BackgroundColor3 = Theme.Color.Accent }):Play()
end))
table.insert(connections, confirmBtn.MouseLeave:Connect(function()
    TweenService:Create(confirmBtn, Theme.Tween.Quick, { BackgroundColor3 = Theme.Color.Accent2 }):Play()
end))
table.insert(connections, confirmBtn.MouseButton1Click:Connect(function()
    close(true)
end))

table.insert(connections, cancelBtn.MouseEnter:Connect(function()
    TweenService:Create(cancelBtn, Theme.Tween.Quick, { BackgroundColor3 = Theme.Color.CardHover }):Play()
    TweenService:Create(cancelLbl, Theme.Tween.Quick, { TextColor3 = Theme.Color.Text }):Play()
end))
table.insert(connections, cancelBtn.MouseLeave:Connect(function()
    TweenService:Create(cancelBtn, Theme.Tween.Quick, { BackgroundColor3 = Theme.Color.Card }):Play()
    TweenService:Create(cancelLbl, Theme.Tween.Quick, { TextColor3 = Theme.Color.TextSub }):Play()
end))
table.insert(connections, cancelBtn.MouseButton1Click:Connect(function()
    close(false)
end))

table.insert(connections, backdrop.MouseButton1Click:Connect(function()
    close(false)
end))

bindable.Event:Wait()
return selection
end

function UILibrary.Window:ChangeCategory(new)
local catFolder = self.MainUI.MainUI.Sidebar.ContentHolder.Cheats.CheatHolder
local Object = catFolder:FindFirstChild(new)

if Object and self.currentSelection ~= Object then
    if self.currentSelection then
        TweenService:Create(
            self.currentSelection.Content.Image,
            UILibrary.TweenInfo,
            {
                ImageColor3 = Color3.fromRGB(118, 124, 148)
            }
        ):Play()

        TweenService:Create(
            self.currentSelection.Content.Title,
            UILibrary.TweenInfo,
            {
                TextColor3 = Color3.fromRGB(118, 124, 148)
            }
        ):Play()

        TweenService:Create(
            self.currentSelection.HoverFrame,
            UILibrary.TweenInfo,
            {
                BackgroundTransparency = 1
            }
        ):Play()

        TweenService:Create(
            self.MainUI.MainUI.Sidebar.Sidebar2[self.currentSelection.Name],
            UILibrary.TweenInfo,
            {
                Position = UDim2.fromScale(1, 0)
            }
        ):Play()
    end

    TweenService:Create(
        Object.Content.Image,
        UILibrary.TweenInfo,
        {
            ImageColor3 = Color3.fromRGB(134, 142, 255)
        }
    ):Play()

    TweenService:Create(
        Object.Content.Title,
        UILibrary.TweenInfo,
        {
            TextColor3 = Color3.fromRGB(134, 142, 255)
        }
    ):Play()

    TweenService:Create(
        Object.HoverFrame,
        UILibrary.TweenInfo,
        {
            BackgroundTransparency = .3
        }
    ):Play()

    TweenService:Create(
        self.MainUI.MainUI.Sidebar.Sidebar2[Object.Name],
        UILibrary.TweenInfo,
        {
            Position = UDim2.fromScale(0, 0)
        }
    ):Play()

    self.currentSelection = Object

    local firstChild = nil

    for i, v in pairs(self.MainUI.MainUI.Sidebar.Sidebar2[Object.Name].Bar2Holder:GetChildren()) do
        if v:IsA("GuiObject") then
            firstChild = v
            break
        end
    end

    if firstChild then
        self:ChangeCategorySelection(firstChild.Name)
    end
end
end

function UILibrary.Window:ChangeCategorySelection(name)
local catFolder = self.MainUI.MainUI.Sidebar.Sidebar2[self.currentSelection.Name].Bar2Holder
local Object = catFolder:FindFirstChild(name)

if Object and self.currentCategorySelection ~= Object then
    if self.currentCategorySelection then
        TweenService:Create(
            self.currentCategorySelection.InnerContent.Image,
            UILibrary.TweenInfo,
            {
                ImageColor3 = Color3.fromRGB(118, 124, 148)
            }
        ):Play()

        TweenService:Create(
            self.currentCategorySelection.InnerContent.Title,
            UILibrary.TweenInfo,
            {
                TextColor3 = Color3.fromRGB(118, 124, 148)
            }
        ):Play()

        TweenService:Create(
            self.currentCategorySelection.HoverFrame,
            UILibrary.TweenInfo,
            {
                BackgroundTransparency = 1
            }
        ):Play()

        TweenService:Create(
            self.currentCategorySelection.SelectionShadow,
            UILibrary.TweenInfo,
            {
                BackgroundTransparency = 1
            }
        ):Play()

        TweenService:Create(
            self.currentTab,
            UILibrary.TweenInfo,
            {
                Position = UDim2.fromScale(0, 1)
            }
        ):Play()
    end

    TweenService:Create(
        Object.InnerContent.Image,
        UILibrary.TweenInfo,
        {
            ImageColor3 = Color3.fromRGB(134, 142, 255)
        }
    ):Play()

    TweenService:Create(
        Object.InnerContent.Title,
        UILibrary.TweenInfo,
        {
            TextColor3 = Color3.fromRGB(134, 142, 255)
        }
    ):Play()

    TweenService:Create(
        Object.HoverFrame,
        UILibrary.TweenInfo,
        {
            BackgroundTransparency = .3
        }
    ):Play()

    TweenService:Create(
        Object.SelectionShadow,
        UILibrary.TweenInfo,
        {
            BackgroundTransparency = .6
        }
    ):Play()

    local tab = self.MainUI.MainUI.Content:FindFirstChild(name)

    if tab then
        TweenService:Create(
            tab,
            UILibrary.TweenInfo,
            {
                Position = UDim2.fromScale(0, 0)
            }
        ):Play()
    end

    self.currentTab = tab
    self.currentCategorySelection = Object
end
end

function UILibrary.Window:Category(name, icon)
local catFolder = self.MainUI.MainUI.Sidebar.ContentHolder.Cheats.CheatHolder
local category = objectGenerator.new("Category")

category.Content.Title.Text = name
category.Content.Image.Image = icon

self.UI[name] = {}

category.Name = name
category.Parent = catFolder
category.LayoutOrder = Utils.getLayoutOrder(catFolder)

local contentHolder = objectGenerator.new("CategoryContent")
contentHolder.Name = name
contentHolder.Visible = true
contentHolder.Parent = self.MainUI.MainUI.Sidebar.Sidebar2

local Hover =
    EffectLib.ButtonHoverEffect(
    category,
    function()
        if self.currentSelection ~= category then
            return true
        else
            return false
        end
    end
)
local Click = EffectLib.ButtonClickEffect(category)

Click.Event:Connect(
    function()
        Utils.CircleClick(category, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)

        self:ChangeCategory(name)
    end
)

if self.currentSelection == nil then
    self:ChangeCategory(name)
end

return setmetatable(
    {
        Effects = {
            Hover = Hover,
            Click = Click
        },
        oldSelf = self,
        categoryUI = category,
        contentHolder = contentHolder
    },
    UILibrary.Category
)
end

end
