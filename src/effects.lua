return function(UILibrary)

local module = {}

local TweenService = game:GetService("TweenService")


module.ButtonHoverEffect = function(ui, req)
    local HoverEvent = Instance.new("BindableEvent")
    local conns = {}

    --// effect here
    local function Start()
        TweenService:Create(
            ui.HoverFrame,
            UILibrary.TweenInfo,
            {
                BackgroundTransparency = .5
            }
        ):Play()
    end

    local function End()
        TweenService:Create(
            ui.HoverFrame,
            UILibrary.TweenInfo,
            {
                BackgroundTransparency = 1
            }
        ):Play()
    end

    local hovering = false

    table.insert(
        conns,
        ui.InputBegan:Connect(
            function(input, gp)
                if gp == true or input.UserInputType ~= Enum.UserInputType.MouseMovement then
                    return
                end

                if req then
                    if req() == false then
                        return
                    end
                end

                hovering = true

                Start()
                HoverEvent:Fire()
            end
        )
    )

    table.insert(
        conns,
        ui.InputEnded:Connect(
            function(input, gp)
                if gp == true or input.UserInputType ~= Enum.UserInputType.MouseMovement then
                    return
                end

                if req then
                    if req() == false then
                        return
                    end
                end

                hovering = false

                End()
            end
        )
    )

    return {
        Event = HoverEvent.Event,
        Disconnect = function()
            for i, v in pairs(conns) do
                conns:Disconnect()
            end

            End()
        end
    }
end

module.ButtonClickEffect = function(ui, req)
    local ClickEvent = Instance.new("BindableEvent")
    local conns = {}

    --// effect here
    local function Start()
        TweenService:Create(
            ui,
            UILibrary.TweenInfo,
            {
                BackgroundTransparency = .5
            }
        ):Play()
    end

    local function End()
        TweenService:Create(
            ui,
            UILibrary.TweenInfo,
            {
                BackgroundTransparency = 1
            }
        ):Play()
    end

    table.insert(
        conns,
        ui.InputBegan:Connect(
            function(input, gp)
                if gp == true or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                    return
                end

                if req then
                    if req() == false then
                        return
                    end
                end

                Start()
            end
        )
    )

    table.insert(
        conns,
        ui.InputEnded:Connect(
            function(input, gp)
                if gp == true or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                    return
                end

                End()

                if req then
                    if req() == false then
                        return
                    end
                end

                ClickEvent:Fire()
            end
        )
    )

    return {
        Event = ClickEvent.Event,
        Disconnect = function()
            for i, v in pairs(conns) do
                conns:Disconnect()
            end

            End()
        end
    }
end

return module

return module
end
