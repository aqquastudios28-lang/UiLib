return function(UILibrary)
    local Utils = require(script.Parent.utils)
    local objectGenerator = require(script.Parent.objectGenerator)
    local Draggable = require(script.Parent.draggable)
    local EffectLib = require(script.Parent.effects)(UILibrary)

    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local TweenService = game:GetService("TweenService")

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

return setmetatable(
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
        MainUI = window
    },
    UILibrary.Window
)
end

function UILibrary.Window:setAnimSpeed(val)
UILibrary.TweenInfo = TweenInfo.new(.4 / (val / 100), Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
end

function UILibrary.Window:Notification(sett)
local Notif = objectGenerator.new("Notification").Main

Notif.Size = UDim2.new(1, 0, 1, -5)
Notif:FindFirstChildOfClass("UIAspectRatioConstraint"):Destroy()

local ui = self.MainUI.Notifications

Notif.Content.Text.Title.Text = sett.Title
Notif.Content.Text.Desc.Text = sett.Desc

local layout = Utils.getLayoutOrder(ui)

Notif.LayoutOrder = layout

    Notif.Notification.Visible = false
    Notif.Parent.Size = UDim2.new(1, 0, 0.1, 5)
    Notif.Parent.Parent = ui
    Notif.Position = UDim2.new(1.5, 0, 0, 0)

    wait(.02)

    TweenService:Create(
        Notif,
        TweenInfo.new(.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Position = UDim2.new(0, 0, 0, 0)
        }
    ):Play()

    local connections = {}
    local isOpen = true

    local function expire()
        isOpen = false

        for i, v in pairs(connections) do
            v:Disconnect()
        end

        TweenService:Create(
            Notif,
            TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                Position = UDim2.new(1.5, 0, 0, 0)
            }
        ):Play()

        task.delay(
            .4,
            function()
                local parent = Notif.Parent
                Notif.Parent:ClearAllChildren()
                parent:Destroy()
            end
        )
    end

--// too fucking lazy to re-encode all instances

if sett.expire then
    task.delay(
        sett.expire,
        function()
            if isOpen then
                expire()
            end
        end
    )
end

table.insert(
    connections,
    Notif.Content.Buttons.InputBegan:Connect(
        function(input, gp)
            if gp then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement then
                TweenService:Create(
                    Notif.Content.Buttons.Close,
                    UILibrary.TweenInfo,
                    {
                        ImageColor3 = Color3.fromRGB(255, 255, 255)
                    }
                ):Play()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                expire()
            end
        end
    )
)

table.insert(
    connections,
    Notif.Content.Buttons.InputEnded:Connect(
        function(input, gp)
            if gp then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement then
                TweenService:Create(
                    Notif.Content.Buttons.Close,
                    UILibrary.TweenInfo,
                    {
                        ImageColor3 = Color3.fromRGB(150, 155, 172)
                    }
                ):Play()
            end
        end
    )
)
end

function UILibrary.Window:Prompt(sett)
local Notif = objectGenerator.new("Prompt").Main

Notif.Size = UDim2.new(1, 0, 1, -5)
Notif:FindFirstChildOfClass("UIAspectRatioConstraint"):Destroy()

local ui = self.MainUI.Notifications

Notif.Content.Text.Title.Text = sett.Title
Notif.Content.Text.Desc.Text = sett.Desc

local layout = Utils.getLayoutOrder(ui)

Notif.LayoutOrder = layout

Notif.Notification.BackgroundTransparency = 0
Notif.Parent.Size = UDim2.fromScale(1, 0)

Notif.Parent.Parent = ui

wait(.02)

TweenService:Create(
    Notif.Parent,
    UILibrary.TweenInfo,
    {
        Size = UDim2.new(1, 0, .1, 5)
    }
):Play()

wait(.2)

TweenService:Create(
    Notif.Notification,
    UILibrary.TweenInfo,
    {
        BackgroundTransparency = 1
    }
):Play()

local connections = {}
local isOpen = true

local selection = nil
local bindable = Instance.new("BindableEvent")

local function expire()
    isOpen = false

    bindable:Fire()

    for i, v in pairs(connections) do
        v:Disconnect()
    end

    TweenService:Create(
        Notif.Notification,
        UILibrary.TweenInfo,
        {
            BackgroundTransparency = 0
        }
    ):Play()

    TweenService:Create(
        Notif,
        TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {
            Position = UDim2.fromScale(2, 0)
            --Size = UDim2.fromScale(0,1)
        }
    ):Play()

    task.delay(
        .3,
        function()
            TweenService:Create(
                Notif.Parent,
                TweenInfo.new(.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
                {
                    Size = UDim2.fromScale(0, 0)
                }
            ):Play()

            local parent = Notif.Parent

            Notif.Parent:ClearAllChildren()

            wait(.3)
            parent:Destroy()
        end
    )

    for i, v in pairs(Notif:GetDescendants()) do
        if v:IsA("ImageLabel") or v:IsA("ImageButton") then
            TweenService:Create(
                v,
                UILibrary.TweenInfo,
                {
                    ImageTransparency = 1
                }
            ):Play()
        elseif v:IsA("TextLabel") then
            TweenService:Create(
                v,
                UILibrary.TweenInfo,
                {
                    TextTransparency = 1
                }
            ):Play()
        end
    end
end

local function extraHitbox(obj, downOrUp)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromScale(1, .35)
    Frame.BackgroundTransparency = 1

    obj.Parent = Frame
    Frame.Name = obj.Name
    obj.Name = "Button"

    obj.Position = UDim2.fromScale(.5, .5 - (.2 / downOrUp))

    return Frame
end

local Parent = Notif.Content.Buttons

local Close = extraHitbox(Notif.Content.Buttons.Close, 1)
Close.LayoutOrder = 1

local Accept = extraHitbox(Notif.Content.Buttons.Accept, -1)

Close.Parent = Parent
Accept.Parent = Parent

table.insert(
    connections,
    Close.InputBegan:Connect(
        function(input, gp)
            if gp then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement then
                TweenService:Create(
                    Close.Button,
                    UILibrary.TweenInfo,
                    {
                        ImageColor3 = Color3.fromRGB(245, 160, 166)
                    }
                ):Play()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                expire()
            end
        end
    )
)

table.insert(
    connections,
    Close.InputEnded:Connect(
        function(input, gp)
            if gp then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement then
                TweenService:Create(
                    Close.Button,
                    UILibrary.TweenInfo,
                    {
                        ImageColor3 = Color3.fromRGB(205, 120, 126)
                    }
                ):Play()
            end
        end
    )
)

table.insert(
    connections,
    Accept.InputBegan:Connect(
        function(input, gp)
            if gp then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement then
                TweenService:Create(
                    Accept.Button,
                    UILibrary.TweenInfo,
                    {
                        ImageColor3 = Color3.fromRGB(170, 235, 185)
                    }
                ):Play()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                selection = true
                expire()
            end
        end
    )
)

table.insert(
    connections,
    Accept.InputEnded:Connect(
        function(input, gp)
            if gp then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement then
                TweenService:Create(
                    Accept.Button,
                    UILibrary.TweenInfo,
                    {
                        ImageColor3 = Color3.fromRGB(118, 190, 136)
                    }
                ):Play()
            end
        end
    )
)

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
