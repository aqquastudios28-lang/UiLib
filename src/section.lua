return function(UILibrary)
    local Utils = require(script.Parent.utils)
    local objectGenerator = require(script.Parent.objectGenerator)

    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")

local cheatInfo = {
["Button"] = {
    FullSize = true
},
["Checkbox"] = {
    TextSize = UDim2.fromScale(.2, 1)
},
["Textbox"] = {
    TextSize = UDim2.fromScale(.4, 1),
    FullSize = true
},
["Dropdown"] = {
    FullSize = true
},
["Slider"] = {
    TextSize = UDim2.fromScale(.45, 1)
},
["Toggle"] = {
    TextSize = UDim2.fromScale(.5, 1)
}
}

local function generateCheatBase(Cheat, sett)
local cheatBase = objectGenerator.new("CheatBase")

local cheatinfo = cheatInfo[Cheat]
local supportsFullSize = cheatinfo ~= nil and cheatinfo.FullSize or false

local Size = supportsFullSize and UDim2.fromScale(1, 1) or UDim2.fromScale(.5, 1)

if sett.Title then
    if sett.Description then
        cheatBase.Content.Text.Text.Text = sett.Title
        cheatBase.Content.Text.Text.Desc.Text = sett.Description

        cheatBase.Content.Text.Text.Desc.Visible = true
        cheatBase.Content.Text.Text.Visible = true
    else
        cheatBase.Content.Text.Text.Text = sett.Title
        cheatBase.Content.Text.Text.Size = UDim2.fromScale(.9, 1)
        cheatBase.Content.Text.Text.Position = UDim2.fromScale(.5, .5)
        cheatBase.Content.Text.Text.Visible = true
    end

    if cheatinfo and cheatinfo.TextSize then
        Size = cheatinfo.TextSize
    else
        Size = UDim2.fromScale(.5, 1)
    end
end

local XSize = 1 - Size.X.Scale

cheatBase.Content.ElementContent.Size = Size
cheatBase.Content.Text.Size = UDim2.fromScale(XSize, 1)

local Content = objectGenerator.new("Cheat", Cheat)

if Content then
    Content.Parent = cheatBase.Content.ElementContent
end

return cheatBase
end

--// some effects because my lazy ass is too lazy to put it in the module
local function setupEffects(ui, hover)
local ClickEvent = Instance.new("BindableEvent")

local uiTweenType =
    (hover:IsA("ImageLabel") or hover:IsA("ImageButton")) and "ImageTransparency" or "BackgroundTransparency"

local function constructTweenInfo(value)
    return {
        [uiTweenType] = value
    }
end

ui.InputBegan:Connect(
    function(input, gp)
        if gp then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(hover, UILibrary.TweenInfo, constructTweenInfo(.5)):Play()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(hover, UILibrary.TweenInfo, constructTweenInfo(.2)):Play()
        end
    end
)

ui.InputEnded:Connect(
    function(input, gp)
        if gp then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(hover, UILibrary.TweenInfo, constructTweenInfo(1)):Play()
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(hover, UILibrary.TweenInfo, constructTweenInfo(.5)):Play()

            ClickEvent:Fire()
        end
    end
)

return ClickEvent.Event
end

function UILibrary.Section:Button(sett, callback)
local functions = {}
functions.__index = functions

local cheatBase = generateCheatBase("Button", sett)
cheatBase.Parent = self.Section.Border.Content
cheatBase.LayoutOrder = Utils.getLayoutOrder(self.Section.Border.Content)

local element = cheatBase.Content.ElementContent.Button

setupEffects(element, element.HoverFrame):Connect(
    function()
        callback()
    end
)

element.Text.Text = sett.ButtonName

local meta =
    setmetatable(
    {
        element = element,
        UI = cheatBase
    },
    functions
)

self.oldSelf.oldSelf.oldSelf.UI[self.oldSelf.oldSelf.categoryUI.Name][self.oldSelf.SectionName][
        self.Section.Name
    ][sett.Title] = meta

return meta
end

function UILibrary.Section:Checkbox(sett, callback)
local functions = {}
functions.__index = functions

local cheatBase = generateCheatBase("Checkbox", sett)
cheatBase.Parent = self.Section.Border.Content
cheatBase.LayoutOrder = Utils.getLayoutOrder(self.Section.Border.Content)

local element = cheatBase.Content.ElementContent.Checkbox

local toggleEnabled = false

functions.setValue = function(new)
    toggleEnabled = new

    if new then
        TweenService:Create(
            element.Selection,
            UILibrary.TweenInfo,
            {
                Size = UDim2.fromScale(.85, .85),
                BackgroundTransparency = 0
            }
        ):Play()
    else
        TweenService:Create(
            element.Selection,
            UILibrary.TweenInfo,
            {
                Size = UDim2.fromScale(0.5, 0.5),
                BackgroundTransparency = 1.1
            }
        ):Play()
    end

    callback(toggleEnabled)
end

functions.getValue = function()
    return toggleEnabled
end

setupEffects(element, element.HoverFrame):Connect(
    function()
        functions.setValue(not toggleEnabled)
    end
)

if sett.Default then
    functions.setValue(sett.Default)
end

local meta =
    setmetatable(
    {
        element = element,
        UI = cheatBase
    },
    functions
)

self.oldSelf.oldSelf.oldSelf.UI[self.oldSelf.oldSelf.categoryUI.Name][self.oldSelf.SectionName][
        self.Section.Name
    ][sett.Title] = meta

return meta
end

function UILibrary.Section:Toggle(sett, callback)
local functions = {}
functions.__index = functions

local cheatBase = generateCheatBase("Toggle", sett)
cheatBase.Parent = self.Section.Border.Content
cheatBase.LayoutOrder = Utils.getLayoutOrder(self.Section.Border.Content)

local element = cheatBase.Content.ElementContent.Toggle

local toggleEnabled = false

functions.setValue = function(new)
    toggleEnabled = new

    if new then
        TweenService:Create(
            element.Content.Frame,
            UILibrary.TweenInfo,
            {
                Position = UDim2.fromScale(.8, .5)
            }
        ):Play()

        TweenService:Create(
            element,
            UILibrary.TweenInfo,
            {
                BackgroundColor3 = Color3.fromRGB(134, 142, 255)
            }
        ):Play()
    else
        TweenService:Create(
            element.Content.Frame,
            UILibrary.TweenInfo,
            {
                Position = UDim2.fromScale(.2, .5)
            }
        ):Play()

        TweenService:Create(
            element,
            UILibrary.TweenInfo,
            {
                BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            }
        ):Play()
    end

    callback(toggleEnabled)
end

functions.getValue = function()
    return toggleEnabled
end

setupEffects(element, element.HoverFrame):Connect(
    function()
        functions.setValue(not toggleEnabled)
    end
)

if sett.Default then
    functions.setValue(sett.Default)
end

local meta =
    setmetatable(
    {
        element = element,
        UI = cheatBase
    },
    functions
)

self.oldSelf.oldSelf.oldSelf.UI[self.oldSelf.oldSelf.categoryUI.Name][self.oldSelf.SectionName][
        self.Section.Name
    ][sett.Title] = meta

return meta
end

function UILibrary.Section:Textbox(sett, callback)
local functions = {}
functions.__index = functions

local cheatBase = generateCheatBase("Textbox", sett)
cheatBase.Parent = self.Section.Border.Content
cheatBase.LayoutOrder = Utils.getLayoutOrder(self.Section.Border.Content)

local element = cheatBase.Content.ElementContent.Textbox

local function updateSize()
    local textBounds = math.clamp(element.Text.TextBounds.X, 10, element.Parent.AbsoluteSize.X) + 20

    TweenService:Create(
        element,
        UILibrary.TweenInfo,
        {
            Size = UDim2.fromScale(textBounds / element.Parent.AbsoluteSize.X, 1)
        }
    ):Play()
end

functions.setValue = function(new)
    --/// anims
    element.Text.Text = new
    updateSize()
    callback(element.Text.Text)
end

functions.getValue = function()
    return element.Text.Text
end

updateSize()

element.Text.Focused:Connect(
    function()
        -- handle as hover
        TweenService:Create(
            element,
            UILibrary.TweenInfo,
            {
                BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            }
        ):Play()

        TweenService:Create(
            element,
            UILibrary.TweenInfo,
            {
                Size = UDim2.fromScale(1, 1)
            }
        ):Play()
    end
)

element.Text.FocusLost:Connect(
    function()
        -- set it here
        TweenService:Create(
            element,
            UILibrary.TweenInfo,
            {
                BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            }
        ):Play()

        functions.setValue(element.Text.Text)
    end
)

if sett.Default then
    functions.setValue(sett.Default)
end

local meta =
    setmetatable(
    {
        element = element,
        UI = cheatBase
    },
    functions
)

self.oldSelf.oldSelf.oldSelf.UI[self.oldSelf.oldSelf.categoryUI.Name][self.oldSelf.SectionName][
        self.Section.Name
    ][sett.Title] = meta

return meta
end

local currentKBInfo = {}

function UILibrary.Section:Keybind(sett, callback)
local functions = {}
functions.__index = functions

local cheatBase = generateCheatBase("Keybind", sett)
cheatBase.Parent = self.Section.Border.Content
cheatBase.LayoutOrder = Utils.getLayoutOrder(self.Section.Border.Content)

local element = cheatBase.Content.ElementContent.Keybind

local function updateSize()
    local textBounds = math.clamp(element.Text.TextBounds.X, 10, element.Parent.AbsoluteSize.X) + 20

    TweenService:Create(
        element,
        UILibrary.TweenInfo,
        {
            Size = UDim2.fromScale(textBounds / element.Parent.AbsoluteSize.X, 1)
        }
    ):Play()
end

local currentKb = nil
local keyPressConn = nil

functions.setValue = function(new)
    --/// anims
    element.Text.Text = new.Name
    updateSize()

    currentKb = new

    if keyPressConn then
        keyPressConn:Disconnect()
    end

    currentKBInfo = {}

    keyPressConn =
        game:GetService("UserInputService").InputBegan:Connect(
        function(input, gp)
            if gp then
                return
            end

            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKb then
                callback()
            elseif input.UserInputType.Name == currentKb.Name then
                callback()
            end
        end
    )
end

functions.getValue = function()
    return currentKb
end

updateSize()

local rebinding = false
local conn

setupEffects(element, element.HoverFrame):Connect(
    function()
        if rebinding then
            return
        end

        if currentKBInfo.old and currentKBInfo.set ~= functions.setValue then
            return
        end

        rebinding = true

        element.Text.Text = "..."
        updateSize()

        local old = functions.getValue()

        conn =
            game:GetService("UserInputService").InputBegan:Connect(
            function(input, gp)
                --if gp then return end

                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKb = input.KeyCode

                    rebinding = false

                    functions.setValue(currentKb)
                    conn:Disconnect()
                elseif
                    input.UserInputType == Enum.UserInputType.MouseButton2 or
                        input.UserInputType == Enum.UserInputType.MouseButton1
                    then
                    currentKb = input.UserInputType

                    rebinding = false

                    functions.setValue(currentKb)
                    conn:Disconnect()
                end
            end
        )

        currentKBInfo.old = old
        currentKBInfo.conn = conn
        currentKBInfo.set = functions.setValue
    end
)

if sett.Default then
    functions.setValue(sett.Default)
end

local meta =
    setmetatable(
    {
        element = element,
        UI = cheatBase
    },
    functions
)
self.oldSelf.oldSelf.oldSelf.UI[self.oldSelf.oldSelf.categoryUI.Name][self.oldSelf.SectionName][
        self.Section.Name
    ][sett.Title] = meta

return meta
end

function toInteger(color)
return math.floor(color.r * 255) * 256 ^ 2 + math.floor(color.g * 255) * 256 + math.floor(color.b * 255)
end

function toHex(color)
local int = toInteger(color)

local current = int
local final = ""

local hexChar = {
    "A",
    "B",
    "C",
    "D",
    "E",
    "F"
}

repeat
    local remainder = current % 16
    local char = tostring(remainder)

    if remainder >= 10 then
        char = hexChar[1 + remainder - 10]
    end

    current = math.floor(current / 16)
    final = final .. char
until current <= 0

return "#" .. string.reverse(final)
end

function UILibrary.Section:ColorPicker(sett, callback)
local functions = {}
functions.__index = functions

local cheatBase = generateCheatBase("ColorPicker", sett)
cheatBase.Parent = self.Section.Border.Content
cheatBase.LayoutOrder = Utils.getLayoutOrder(self.Section.Border.Content)

local element = cheatBase.Content.ElementContent.ColorPicker

local menuIsOpen = false
local currentclr = Color3.fromRGB(255, 255, 255)

functions.setValue = function(clr)
    TweenService:Create(
        element.Preview,
        UILibrary.TweenInfo,
        {
            ImageColor3 = clr
        }
    ):Play()

    currentclr = clr

    callback(clr)
    element.Text.Label.Text =
        math.floor(clr.R * 255) .. ", " .. math.floor(clr.G * 255) .. ", " .. math.floor(clr.B * 255)
end

functions.getValue = function()
    return currentclr
end

functions.openMenu = function()
    if menuIsOpen == true then
        return
    end

    menuIsOpen = true

    local oldColor
    local oldPos

    self.MainSelf.MainUI.MainUI.ColorPickerOverlay.Visible = true

    TweenService:Create(
        self.MainSelf.MainUI.MainUI.ColorPickerOverlay,
        UILibrary.TweenInfo,
        {
            ImageTransparency = .07
        }
    ):Play()

    TweenService:Create(
        self.MainSelf.MainUI.MainUI.ColorPickerOverlay.Content,
        UILibrary.TweenInfo,
        {
            Position = UDim2.fromScale(.5, 0.5)
        }
    ):Play()

    local Content = self.MainSelf.MainUI.MainUI.ColorPickerOverlay.Content
    local colourWheel = Content.MainWindow.Wheel
    local darknessSlider = Content.MainWindow.Saturation.Pointer
    local darknessPicker = Content.MainWindow.Saturation

    local function updateWheel()
        local centreOfWheel =
            Vector2.new(
            colourWheel.AbsolutePosition.X + (colourWheel.AbsoluteSize.X / 2),
            colourWheel.AbsolutePosition.Y + (colourWheel.AbsoluteSize.Y / 2)
        )

        local colourPickerCentre =
            Vector2.new(
            colourWheel.Pointer.AbsolutePosition.X + (colourWheel.Pointer.AbsoluteSize.X / 2),
            colourWheel.Pointer.AbsolutePosition.Y + (colourWheel.Pointer.AbsoluteSize.Y / 2)
        )

        local h =
            (math.pi -
            math.atan2(colourPickerCentre.Y - centreOfWheel.Y, colourPickerCentre.X - centreOfWheel.X)) /
            (math.pi * 2)

        local s = (centreOfWheel - colourPickerCentre).Magnitude / (colourWheel.AbsoluteSize.X / 2)

        local v =
            math.abs(
            (darknessSlider.AbsolutePosition.Y - darknessPicker.AbsolutePosition.Y) /
                darknessPicker.AbsoluteSize.Y -
                1
        )

        local hsv = Color3.fromHSV(math.clamp(h, 0, 1), math.clamp(s, 0, 1), math.clamp(v, 0, 1))

        return hsv, Color3.fromHSV(math.clamp(h, 0, 1), math.clamp(s, 0, 1), 1)
    end

    local holdingHsv = false
    local holdingSaturation = false

    local connections = {}

    table.insert(
        connections,
        self.MainSelf.MainUI.MainUI.ColorPickerOverlay.Content.MainWindow.Wheel.Hitbox.InputBegan:Connect(
            function(input, gp)
                if gp == true then
                    return
                end

                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    holdingHsv = true
                end
            end
        )
    )

    table.insert(
        connections,
        self.MainSelf.MainUI.MainUI.ColorPickerOverlay.Content.MainWindow.Wheel.Hitbox.InputEnded:Connect(
            function(input, gp)
                if gp == true then
                    return
                end

                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    holdingHsv = false
                end
            end
        )
    )

    table.insert(
        connections,
        self.MainSelf.MainUI.MainUI.ColorPickerOverlay.Content.MainWindow.Saturation.Hitbox.InputBegan:Connect(
            function(input, gp)
                if gp == true then
                    return
                end

                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    holdingSaturation = true
                end
            end
        )
    )

    table.insert(
        connections,
        self.MainSelf.MainUI.MainUI.ColorPickerOverlay.Content.MainWindow.Saturation.Hitbox.InputEnded:Connect(
            function(input, gp)
                if gp == true then
                    return
                end

                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    holdingSaturation = false
                end
            end
        )
    )

    table.insert(
        connections,
        RunService.RenderStepped:Connect(
            function()
                local mousePos =
                    game:GetService("UserInputService"):GetMouseLocation() -
                    Vector2.new(0, game:GetService("GuiService"):GetGuiInset().Y)

                local centreOfWheel =
                    Vector2.new(
                    colourWheel.AbsolutePosition.X + (colourWheel.AbsoluteSize.X / 2),
                    colourWheel.AbsolutePosition.Y + (colourWheel.AbsoluteSize.Y / 2)
                )

                local distanceFromWheel = (mousePos - centreOfWheel).Magnitude

                if holdingHsv then
                    if distanceFromWheel <= colourWheel.AbsoluteSize.X / 2 then
                        colourWheel.Pointer.Position =
                            UDim2.new(
                            0,
                            mousePos.X - colourWheel.AbsolutePosition.X,
                            0,
                            mousePos.Y - colourWheel.AbsolutePosition.Y
                        )
                    end
                end

                if holdingSaturation then
                    darknessSlider.Position =
                        UDim2.new(
                        darknessSlider.Position.X.Scale,
                        0,
                        0,
                        math.clamp(
                            mousePos.Y - darknessPicker.AbsolutePosition.Y,
                            0,
                            darknessPicker.AbsoluteSize.Y
                        )
                    )
                end

                local clr, new = updateWheel()

                darknessPicker.ImageColor3 = new

                if clr ~= oldColor then
                    oldColor = clr

                    Content.ClrDisplay.RGB.Textbox.Text =
                        math.floor(clr.R * 255) ..
                        ", " .. math.floor(clr.G * 255) .. ", " .. math.floor(clr.B * 255)
                    Content.ClrDisplay.Hex.Textbox.Text = toHex(clr)
                end
            end
        )
    )

    local function closeMenu()
        for i, v in pairs(connections) do
            v:Disconnect()
        end

        TweenService:Create(
            self.MainSelf.MainUI.MainUI.ColorPickerOverlay,
            UILibrary.TweenInfo,
            {
                ImageTransparency = 1
            }
        ):Play()

        TweenService:Create(
            self.MainSelf.MainUI.MainUI.ColorPickerOverlay.Content,
            UILibrary.TweenInfo,
            {
                Position = UDim2.fromScale(.5, 1.5)
            }
        ):Play()

        wait(.5)
        self.MainSelf.MainUI.MainUI.ColorPickerOverlay.Visible = false
        menuIsOpen = false
    end

    table.insert(
        connections,
        Content.Buttons.Cancel.InputBegan:Connect(
            function(input, gp)
                if gp == true then
                    return
                end

                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    closeMenu()
                elseif input.UserInputType == Enum.UserInputType.MouseMovement then
                    TweenService:Create(
                        Content.Buttons.Cancel.OtherFill,
                        UILibrary.TweenInfo,
                        {
                            ImageColor3 = Color3.fromRGB(150, 69, 71)
                        }
                    ):Play()
                end
            end
        )
    )

    table.insert(
        connections,
        Content.Buttons.Cancel.InputEnded:Connect(
            function(input, gp)
                if gp == true then
                    return
                end

                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    TweenService:Create(
                        Content.Buttons.Cancel.OtherFill,
                        UILibrary.TweenInfo,
                        {
                            ImageColor3 = Color3.fromRGB(170, 89, 91)
                        }
                    ):Play()
                end
            end
        )
    )

    table.insert(
        connections,
        Content.Buttons.Confirm.InputBegan:Connect(
            function(input, gp)
                if gp == true then
                    return
                end

                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local actual, clr = updateWheel()

                    functions.setValue(actual)

                    closeMenu()
                elseif input.UserInputType == Enum.UserInputType.MouseMovement then
                    TweenService:Create(
                        Content.Buttons.Confirm.OtherFill,
                        UILibrary.TweenInfo,
                        {
                            ImageColor3 = Color3.fromRGB(60, 150, 107)
                        }
                    ):Play()
                end
            end
        )
    )

    table.insert(
        connections,
        Content.Buttons.Confirm.InputEnded:Connect(
            function(input, gp)
                if gp == true then
                    return
                end

                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    TweenService:Create(
                        Content.Buttons.Confirm.OtherFill,
                        UILibrary.TweenInfo,
                        {
                            ImageColor3 = Color3.fromRGB(85, 170, 127)
                        }
                    ):Play()
                end
            end
        )
    )
end

element.Text.Label.Focused:Connect(
    function()
        TweenService:Create(
            element.Text,
            UILibrary.TweenInfo,
            {
                ImageColor3 = Color3.fromRGB(20, 20, 20)
            }
        ):Play()
    end
)

element.Text.Label.FocusLost:Connect(
    function()
        TweenService:Create(
            element.Text,
            UILibrary.TweenInfo,
            {
                ImageColor3 = Color3.fromRGB(25, 25, 25)
            }
        ):Play()

        local split = element.Text.Label.Text:split(",")

        if #split == 3 then
            for i, v in pairs(split) do
                if tonumber(v) == nil then
                    element.Text.Label.Text =
                        math.floor(currentclr.R * 255) ..
                        ", " .. math.floor(currentclr.G * 255) .. ", " .. math.floor(currentclr.B * 255)
                    return
                end
            end

            local clr3 = Color3.fromRGB(split[1], split[2], split[3])

            functions.setValue(clr3)
        else
            element.Text.Label.Text =
                math.floor(currentclr.R * 255) ..
                ", " .. math.floor(currentclr.G * 255) .. ", " .. math.floor(currentclr.B * 255)
        end
    end
)

setupEffects(element.Preview, element.Preview.Hover):Connect(
    function()
        functions.openMenu()
    end
)

if sett.Default then
    functions.setValue(sett.Default)
else
    functions.setValue(Color3.fromRGB(255, 255, 255))
end

local meta =
    setmetatable(
    {
        element = element,
        UI = cheatBase
    },
    functions
)

self.oldSelf.oldSelf.oldSelf.UI[self.oldSelf.oldSelf.categoryUI.Name][self.oldSelf.SectionName][
        self.Section.Name
    ][sett.Title] = meta

return meta
end

function UILibrary.Section:Slider(sett, callback)
local functions = {}
functions.__index = functions

local cheatBase = generateCheatBase("Slider", sett)
cheatBase.Parent = self.Section.Border.Content
cheatBase.LayoutOrder = Utils.getLayoutOrder(self.Section.Border.Content)

local element = cheatBase.Content.ElementContent.Slider

if sett.Min == nil then
    sett.Min = 0
end

if sett.Max == nil then
    sett.Max = 10
end

local sliderValue = sett.Min
local scaleValue = 0

functions.getData = function()
    return sett
end

functions.setValue = function(v, scale)
    sliderValue = math.floor(v)
    scaleValue = scale

    element.KeyInput.Text.Text = tostring(math.floor(v))

    TweenService:Create(
        element.Drag.Frame.UIGradient,
        UILibrary.TweenInfo,
        {
            Offset = Vector2.new(scaleValue, 0)
        }
    ):Play()

    callback(v)
end

functions.getValue = function()
    return sliderValue
end

element.KeyInput.Text.Focused:Connect(
    function()
        TweenService:Create(
            element.KeyInput,
            UILibrary.TweenInfo,
            {
                BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            }
        ):Play()
    end
)

element.KeyInput.Text.FocusLost:Connect(
    function()
        TweenService:Create(
            element.KeyInput,
            UILibrary.TweenInfo,
            {
                BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            }
        ):Play()

        if tonumber(element.KeyInput.Text.Text) then
            element.KeyInput.Text.Text = math.clamp(tonumber(element.KeyInput.Text.Text), sett.Min, sett.Max)
        end

        if tonumber(element.KeyInput.Text.Text) then
            local scale = math.clamp(tonumber(element.KeyInput.Text.Text) / sett.Max, 0, 1)

            functions.setValue(tonumber(element.KeyInput.Text.Text), scale)
        else
            element.KeyInput.Text.Text = tostring(math.floor(sliderValue))
        end
    end
)

local holding = false

RunService.RenderStepped:Connect(
    function()
        if holding then
            local mouseX = LocalPlayer:GetMouse().X
            local sliderPos = element.Drag.AbsolutePosition.X

            local leftBoundary = element.Drag.AbsolutePosition.X - (element.Drag.AbsoluteSize.X)

            local rightBoundary = element.Drag.AbsolutePosition.X + (element.Drag.AbsoluteSize.X)

            local maxPos = math.clamp((mouseX - sliderPos) / (rightBoundary - sliderPos), 0, 1)

            local val = ((sett.Max - sett.Min) * maxPos) + sett.Min

            functions.setValue(val, maxPos)
        end
    end
)

element.Drag.InputBegan:Connect(
    function(input, gp)
        if gp == true then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            holding = true
        end
    end
)

element.Drag.InputEnded:Connect(
    function(input, gp)
        if gp == true then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            holding = false
        end
    end
)

if sett.Default then
    local scale = math.clamp(tonumber(sett.Default) / sett.Max, 0, 1)
    functions.setValue(tonumber(sett.Default), scale)
else
    local scale = math.clamp((((sett.Max - sett.Min) / 2) + sett.Min) / sett.Max, 0, 1)
    functions.setValue(tonumber((((sett.Max - sett.Min) / 2) + sett.Min)), scale)
end

local meta =
    setmetatable(
    {
        element = element,
        UI = cheatBase
    },
    functions
)

self.oldSelf.oldSelf.oldSelf.UI[self.oldSelf.oldSelf.categoryUI.Name][self.oldSelf.SectionName][
        self.Section.Name
    ][sett.Title] = meta

return meta
end

function UILibrary.Section:Dropdown(sett, callback)
local functions = {}
functions.__index = functions

local cheatBase = generateCheatBase("Dropdown", sett)
cheatBase.Parent = self.Section.Border.Content
cheatBase.LayoutOrder = Utils.getLayoutOrder(self.Section.Border.Content)

local element = cheatBase.Content.ElementContent.Dropdown

local slot = element.Slot:Clone()
element.Slot:Destroy()

local bottom = element.Bottom:Clone()
element.Bottom:Destroy()

local top = element.Top:Clone()
element.Top:Destroy()

local conns = {}
local menuOpen = false

local options = sett.Options ~= nil and sett.Options or {}
local selectedOptions = {}

local optionConnections = {}

functions.refreshUI = function()
    local String = ""

    for i, v in pairs(options) do
        local ui = element.OptionHolder.ContentHolder.Content:FindFirstChild(i)

        if options[i] then
            TweenService:Create(
                ui.Select,
                UILibrary.TweenInfo,
                {
                    ImageTransparency = 0
                }
            ):Play()

            if String == "" then
                String = i
            else
                String = String .. ", " .. i
            end
        else
            TweenService:Create(
                ui.Select,
                UILibrary.TweenInfo,
                {
                    ImageTransparency = 1
                }
            ):Play()
        end
    end

    if String == "" then
        String = "None"
    end

    element.MainHolder.Content.Text.Text = String
end

functions.setValue = function(option, value, isDefault)
    if options[option] ~= nil then
        if element.OptionHolder.ContentHolder.Content:FindFirstChild(option) then
            if sett.Multi == true then
                options[option] = value

                functions.refreshUI()
            else
                if value == true then
                    for i, v in pairs(options) do
                        options[i] = false
                    end

                    if isDefault == nil then
                        functions.openMenu()
                    end

                    options[option] = true

                    functions.refreshUI()
                end
            end

            callback(options)
        end
    end
end

local function updateDropdown()
    for i, v in pairs(element.OptionHolder.ContentHolder.Content:GetChildren()) do
        if v:IsA("GuiObject") then
            v:Destroy()
        end
    end

    for i, v in pairs(optionConnections) do
        v:Disconnect()
    end

    local counter = 0
    local totalCounter = 0

    for i, v in pairs(options) do
        totalCounter = totalCounter + 1
    end

    for v, i in pairs(options) do
        local Option

        counter = counter + 1

        if counter == totalCounter then
            Option = bottom:Clone()
        elseif counter ~= 1 then
            Option = slot:Clone()
        else
            Option = top:Clone()
        end

        Option.Name = v
        Option.Parent = element.OptionHolder.ContentHolder.Content
        Option.LayoutOrder = i
        Option.Size = UDim2.fromScale(1, 1 / totalCounter)

        Option.Current.Text = v

        table.insert(
            optionConnections,
            Option.InputBegan:Connect(
                function(input, gp)
                    if gp then
                        return
                    end

                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        functions.setValue(v, not options[v])
                    elseif input.UserInputType == Enum.UserInputType.MouseMovement then
                        TweenService:Create(
                            Option,
                            UILibrary.TweenInfo,
                            {
                                ImageColor3 = Color3.fromRGB(20, 20, 20)
                            }
                        ):Play()
                    end
                end
            )
        )

        table.insert(
            optionConnections,
            Option.InputEnded:Connect(
                function(input, gp)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        TweenService:Create(
                            Option,
                            UILibrary.TweenInfo,
                            {
                                ImageColor3 = Color3.fromRGB(25, 25, 25)
                            }
                        ):Play()
                    end
                end
            )
        )
    end
end

updateDropdown()

functions.updateDropdown = function(new)
    options = new

    updateDropdown()
    functions.refreshUI()
end

functions.openMenu = function()
    local totalCounter = 0

    for i, v in pairs(options) do
        totalCounter = totalCounter + 1
    end

    if totalCounter == 0 then
        return
    end

    menuOpen = not menuOpen

    if menuOpen then
        TweenService:Create(
            element.MainHolder.Content.Icon.Holder,
            UILibrary.TweenInfo,
            {
                Rotation = 180
            }
        ):Play()

        TweenService:Create(
            element.OptionHolder,
            UILibrary.TweenInfo,
            {
                Size = UDim2.fromScale(1, math.clamp(totalCounter, 0, 999) * .7)
            }
        ):Play()

        local n = 15 + (10 * math.clamp(totalCounter, 0, 3))

        TweenService:Create(
            element.OptionHolder.Cover.DropShadow,
            UILibrary.TweenInfo,
            {
                ImageTransparency = 0.5,
                Size = UDim2.new(1, n, 1, n)
            }
        ):Play()

        element.OptionHolder.Visible = true

        task.delay(
            .4,
            function()
                if menuOpen then
                    TweenService:Create(
                        element.OptionHolder.Cover,
                        UILibrary.TweenInfo,
                        {
                            BackgroundTransparency = 1
                        }
                    ):Play()
                end
            end
        )
    else
        TweenService:Create(
            element.MainHolder.Content.Icon.Holder,
            UILibrary.TweenInfo,
            {
                Rotation = 0
            }
        ):Play()

        TweenService:Create(
            element.OptionHolder,
            UILibrary.TweenInfo,
            {
                Size = UDim2.fromScale(1, 0)
            }
        ):Play()

        TweenService:Create(
            element.OptionHolder.Cover.DropShadow,
            UILibrary.TweenInfo,
            {
                ImageTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0)
            }
        ):Play()

        TweenService:Create(
            element.OptionHolder.Cover,
            TweenInfo.new(.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
            {
                BackgroundTransparency = 0
            }
        ):Play()

        task.delay(
            .4,
            function()
                if menuOpen then
                    return
                end

                element.OptionHolder.Visible = false
            end
        )
    end
end

functions.getValue = function()
    return options
end

table.insert(
    conns,
    element.MainHolder.Content.Icon.InputBegan:Connect(
        function(input, gp)
            if gp then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement then
                TweenService:Create(
                    element.MainHolder.Content.Icon.Holder.Icon,
                    UILibrary.TweenInfo,
                    {
                        Position = UDim2.fromScale(0, .2),
                        ImageColor3 = Color3.fromRGB(50, 50, 50)
                    }
                ):Play()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                functions.openMenu()
            end
        end
    )
)

table.insert(
    conns,
    element.MainHolder.Content.Icon.InputEnded:Connect(
        function(input, gp)
            if gp then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement then
                TweenService:Create(
                    element.MainHolder.Content.Icon.Holder.Icon,
                    UILibrary.TweenInfo,
                    {
                        Position = UDim2.fromScale(0, 0),
                        ImageColor3 = Color3.fromRGB(100, 100, 100)
                    }
                ):Play()
            end
        end
    )
)

if sett.Default then
    functions.setValue(sett.Default, true, true)
end

local meta =
    setmetatable(
    {
        element = element,
        UI = cheatBase
    },
    functions
)

self.oldSelf.oldSelf.oldSelf.UI[self.oldSelf.oldSelf.categoryUI.Name][self.oldSelf.SectionName][
        self.Section.Name
    ][sett.Title] = meta

return meta
end


end
