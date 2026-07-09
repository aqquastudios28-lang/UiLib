local utils = {}

local camera = workspace.Camera.ViewportSize
local centre = Vector2.new(camera.X/2, camera.Y/2)

utils.OffsetToScale = function(Offset)
    return ({Offset[1] / camera.X, Offset[2] / camera.Y})
end

utils.ScaleToOffset = function(Scale)
    local X = Scale[1] * camera.X
    local Y = Scale[2] * camera.Y
    return X , Y
end

utils.CheckBoundary = function(Boundary,Object,Change)
    if Boundary then
        local Size = Boundary.AbsoluteSize
        local Position = Boundary.AbsolutePosition
        
        local Min = -(Size-Position) + Size
        local Max = (Size+Position) - Object.AbsoluteSize
        
        local ObjPos = Object.Position
        local X , Y = utils.ScaleToOffset({ObjPos.X.Scale,ObjPos.Y.Scale})
        
        local GuiVector = Vector2.new(ObjPos.X.Offset+Change.X+X,ObjPos.Y.Offset+Change.Y+Y)
        
        X = math.clamp(GuiVector.X,Min.X,Max.X)
        Y = math.clamp(GuiVector.Y,Min.Y,Max.Y)
        
        return X , Y
    end
end

utils.SortTable = function(Clippings , Current , Object)
    Clippings = Clippings or {}
    Current = Current or {}
    local Suitable
    local CurrentDist
    
    pcall(function()
        if Object then
            for _ , v in ipairs(Current) do
                if table.find(Clippings,v) and v.ZIndex <= Object.ZIndex then
                    if not CurrentDist then
                        CurrentDist = (Object.AbsolutePosition-v.AbsolutePosition).Magnitude
                        Suitable = v
                    else
                        local Dist = (Object.AbsolutePosition-v.AbsolutePosition).Magnitude
                        if Dist < CurrentDist then
                            CurrentDist = Dist
                            Suitable = v
                        end
                    end
                end
            end
        end
    end)
    
    return Suitable
end

utils.Side = function(E)
    if E >= -135 and E <= -45 then
        return 'Left'
    elseif E <= 45 and E > -45 then
        return 'Down'
    elseif E  <= 135 and E > 45 then
        return 'Right'
    else 
        return 'Up'
    end
end

utils.Snap = function(B,C,Target)
    local aPos = C.AbsolutePosition - centre
    local bPos = B.AbsolutePosition - centre
    local bPos = aPos - bPos
    
    local Dot = math.deg(math.atan2(bPos.X, bPos.Y))
    
    local SideGot = utils.Side(Dot)
    local Size = B.Size
    local CSize = C.Size
    
    local CSizeX,CSizeY= table.unpack(utils.OffsetToScale({CSize.X.Offset,CSize.Y.Offset})) 
    CSizeX = CSizeX + CSize.X.Scale
    CSizeY = CSizeY + CSize.Y.Scale
    
    local Size1,Size2 = table.unpack(utils.OffsetToScale({Size.X.Offset,Size.Y.Offset}))
    Size1 = Size1 + Size.X.Scale
    Size2 = Size2 + Size.Y.Scale
    
    local Size = {Size1,Size2}

    local Pos1,Pos2 = table.unpack(utils.OffsetToScale({B.Position.X.Offset,B.Position.Y.Offset}))
    local X =  (Target and utils.OffsetToScale({Target.X.Offset,0})[1])  or utils.OffsetToScale({C.Position.X.Offset,0})[1]
    local Y =  (Target and utils.OffsetToScale({0,Target.Y.Offset})[2])  or utils.OffsetToScale({0,C.Position.Y.Offset})[2]
    
    if SideGot == 'Up' then
        local Pos = UDim2.new(X,0,Pos2+B.Position.Y.Scale,0)
        Size[2] = Size[2] + CSizeY-Size2
        return Pos+ UDim2.new(0,0,-Size[2],0)
    elseif SideGot == 'Down' then
        local Pos = UDim2.new(X,0,Pos2+B.Position.Y.Scale,0)
        return Pos+ UDim2.new(0,0,Size[2],0)
    elseif SideGot == 'Left' then
        local Pos = UDim2.new(Pos1+B.Position.X.Scale,0,Y,0)
        Size[1] = Size[1] + CSizeX-Size1
        return Pos+ UDim2.new(-Size[1],0,0,0)
    elseif SideGot == 'Right' then
        local Pos = UDim2.new(Pos1+B.Position.X.Scale,0,Y,0)
        return Pos+ UDim2.new(Size[1],0,0,0)
    end
end

utils.CircleClick = function(Button)
    local circle = Instance.new("Frame")
    Instance.new("UICorner", circle)
    
    circle.UICorner.CornerRadius = UDim.new(1, 0)
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.BackgroundColor3 = Color3.fromRGB(0,0,0)
    circle.Position = UDim2.new(0, game.Players.LocalPlayer:GetMouse().X - Button.AbsolutePosition.X, 0, game.Players.LocalPlayer:GetMouse().Y - Button.AbsolutePosition.Y)
    circle.Size = UDim2.new(0, 1, 0, 1)
    circle.Transparency = .8
    circle.ZIndex = 999
    
    circle.Parent = Button
    
    local finalGoal = {}
    finalGoal.Size = UDim2.new(0, (Button.AbsoluteSize.X), 0, (Button.AbsoluteSize.X))
    finalGoal.Transparency = 1
    
    game.Debris:AddItem(circle,.4)
    
    local tween = game:GetService("TweenService"):Create(circle, TweenInfo.new(.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), finalGoal)
    tween:Play()
end

utils.getLayoutOrder = function(UI)
    local layoutTable = {0}

    for i, v in pairs(UI:GetChildren()) do
        if v:IsA("GuiObject") then
            table.insert(layoutTable, v.LayoutOrder)
        end
    end

    return math.max(unpack(layoutTable)) + 1
end

return utils
