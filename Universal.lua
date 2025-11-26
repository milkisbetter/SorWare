return function(Window, Library, SaveManager, ThemeManager, Addons, Toggles, Options)
    -- // SERVICES //
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local Camera = Workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    local VirtualUser = game:GetService("VirtualUser")

    -- // VARIABLES //
    local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 1; FOVCircle.NumSides = 60; FOVCircle.Filled = false; FOVCircle.Transparency = 1; FOVCircle.Visible = false
    local CrosshairX = Drawing.new("Line"); local CrosshairY = Drawing.new("Line")
    local CrosshairCircle = Drawing.new("Circle"); local CrosshairDot = Drawing.new("Circle")
    local CrosshairRotation = 0
    local LockedTarget = nil 
    local OriginalLighting = { Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient }

    -- // HELPER FUNCTIONS //
    local function IsVisible(targetPart)
        if not targetPart then return false end
        local origin = Camera.CFrame.Position
        local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        local result = Workspace:Raycast(origin, direction, raycastParams)
        return result == nil
    end

    local function GetClosestPlayer()
        if not Options.AimbotFOV then return nil end
        local fov = Options.AimbotFOV.Value
        local closest = nil
        local shortestDist = math.huge
        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                if Toggles.TeamCheck.Value and plr.Team == LocalPlayer.Team then continue end
                
                local targetPartName = (Options.TargetPart and Options.TargetPart.Value) or "Head"
                local targetPart = plr.Character:FindFirstChild(targetPartName)
                if not targetPart then continue end

                if Toggles.WallCheck.Value and not IsVisible(targetPart) then continue end

                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (mousePos - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < fov and dist < shortestDist then
                        closest = plr
                        shortestDist = dist
                    end
                end
            end
        end
        return closest
    end

    -- // TABS //
    local Tabs = {
        Combat = Window:AddTab('Combat'),
        Visuals = Window:AddTab('Visuals'),
        Misc = Window:AddTab('Misc'),
        Settings = Window:AddTab('Settings')
    }

    -- COMBAT
    local CombatBox = Tabs.Combat:AddLeftGroupbox('Aimbot')
    CombatBox:AddToggle('AimbotEnabled', { Text = 'Enabled', Default = false }):AddKeyPicker('AimbotKey', { Default = 'MB2', Text = 'Aimbot Key', Mode = 'Hold' })
    CombatBox:AddDropdown('AimbotMethod', { Values = { 'Camera', 'Mouse', 'Character' }, Default = 1, Multi = false, Text = 'Method' })
    CombatBox:AddDropdown('TargetPart', { Values = { 'Head', 'HumanoidRootPart', 'Torso' }, Default = 1, Multi = false, Text = 'Target Part' })
    CombatBox:AddSlider('AimbotSmoothing', { Text = 'Smoothing', Default = 0.5, Min = 0.01, Max = 1, Rounding = 2 })
    CombatBox:AddDivider()
    CombatBox:AddToggle('StickyAim', { Text = 'Sticky Aim', Default = false })
    CombatBox:AddToggle('TeamCheck', { Text = 'Team Check', Default = true })
    CombatBox:AddToggle('WallCheck', { Text = 'Wall Check', Default = false })
    CombatBox:AddToggle('Prediction', { Text = 'Prediction', Default = false })
    CombatBox:AddSlider('PredAmount', { Text = 'Prediction Amount', Default = 0.16, Min = 0.1, Max = 1, Rounding = 2 })
    
    local TriggerBox = Tabs.Combat:AddRightGroupbox('TriggerBot')
    TriggerBox:AddToggle('TriggerEnabled', { Text = 'Enabled', Default = false }):AddKeyPicker('TriggerKey', { Default = 'T', Text = 'Trigger Key', Mode = 'Hold' })
    TriggerBox:AddSlider('TriggerDelay', { Text = 'Click Delay', Default = 0.1, Min = 0, Max = 1, Rounding = 2 })

    local FovBox = Tabs.Combat:AddRightGroupbox('FOV Settings')
    FovBox:AddToggle('ShowFOV', { Text = 'Draw FOV Circle', Default = false }):AddColorPicker('FOVColor', { Default = Color3.fromRGB(255, 255, 255) })
    FovBox:AddSlider('AimbotFOV', { Text = 'FOV Radius', Default = 100, Min = 10, Max = 800, Rounding = 0 })

    -- VISUALS
    local EspBox = Tabs.Visuals:AddLeftGroupbox('ESP (Sense)')
    EspBox:AddToggle('EspEnabled', { Text = 'Master Switch', Default = false })
    EspBox:AddToggle('EspBoxes', { Text = 'Boxes', Default = false }):AddColorPicker('BoxColor', { Default = Color3.fromRGB(255, 0, 0), Title = 'Box Color' })
    EspBox:AddToggle('EspNames', { Text = 'Names', Default = false }):AddColorPicker('NameColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'Name Color' })
    EspBox:AddToggle('EspHealth', { Text = 'Health Bar', Default = false })
    EspBox:AddToggle('EspTool', { Text = 'Weapon Text', Default = false })
    EspBox:AddToggle('EspDist', { Text = 'Distance Text', Default = false })
    EspBox:AddSlider('EspTextSize', { Text = 'Text Size', Default = 13, Min = 8, Max = 24, Rounding = 0 })

    local WorldBox = Tabs.Visuals:AddRightGroupbox('World')
    WorldBox:AddToggle('Fullbright', { Text = 'Fullbright', Default = false })
    WorldBox:AddToggle('CustomFOV', { Text = 'Custom Camera FOV', Default = false })
    WorldBox:AddSlider('CamFOVAmount', { Text = 'Field of View', Default = 90, Min = 70, Max = 120, Rounding = 0 })
    WorldBox:AddToggle('TimeChanger', { Text = 'Time Changer', Default = false })
    WorldBox:AddSlider('TimeAmount', { Text = 'Time', Default = 12, Min = 0, Max = 24, Rounding = 1 })
    
    WorldBox:AddDivider()
    WorldBox:AddToggle('Crosshair', { Text = 'Custom Crosshair', Default = false }):AddColorPicker('CrosshairColor', { Default = Color3.fromRGB(0, 255, 0) })
    WorldBox:AddDropdown('CrosshairType', { Values = { 'Line', 'Circle', 'Dot' }, Default = 1, Multi = false, Text = 'Type' })
    WorldBox:AddSlider('CrosshairSize', { Text = 'Size', Default = 20, Min = 2, Max = 100, Rounding = 0 })
    WorldBox:AddSlider('CrosshairThickness', { Text = 'Thickness', Default = 2, Min = 1, Max = 10, Rounding = 0 })
    WorldBox:AddToggle('CrosshairSpin', { Text = 'Spinning', Default = false })
    WorldBox:AddSlider('CrosshairSpinSpeed', { Text = 'Spin Speed', Default = 100, Min = 10, Max = 500, Rounding = 0 })

    -- MISC
    local MoveBox = Tabs.Misc:AddLeftGroupbox('Movement')
    MoveBox:AddToggle('FlightEnabled', { Text = 'Enable Flight', Default = false }):AddKeyPicker('FlightKey', { Default = 'V', Text = 'Flight Toggle', Mode = 'Toggle' })
    MoveBox:AddSlider('FlightSpeed', { Text = 'Flight Speed', Default = 50, Min = 10, Max = 300, Rounding = 0 })
    MoveBox:AddToggle('Noclip', { Text = 'Noclip', Default = false })
    MoveBox:AddDropdown('NoclipMethod', { Values = { 'Standard', 'CFrame' }, Default = 1, Multi = false, Text = 'Noclip Method' })
    MoveBox:AddToggle('InfJump', { Text = 'Infinite Jump', Default = false })

    local SpinBox = Tabs.Misc:AddLeftGroupbox('Spinbot')
    SpinBox:AddToggle('Spinbot', { Text = 'Enable Spinbot', Default = false })
    SpinBox:AddSlider('SpinSpeed', { Text = 'Spin Speed', Default = 20, Min = 1, Max = 100, Rounding = 0 })

    local UtilBox = Tabs.Misc:AddRightGroupbox('Utilities')
    UtilBox:AddToggle('AntiAFK', { Text = 'Anti-AFK', Default = false })
    UtilBox:AddButton('Rejoin Server', function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)

    local ModBox = Tabs.Misc:AddRightGroupbox('Modifiers')
    ModBox:AddToggle('WalkSpeedEnabled', { Text = 'Enable WalkSpeed', Default = false })
    ModBox:AddSlider('WalkSpeedVal', { Text = 'Walk Speed', Default = 16, Min = 16, Max = 300, Rounding = 0 })
    ModBox:AddToggle('JumpPowerEnabled', { Text = 'Enable JumpPower', Default = false })
    ModBox:AddSlider('JumpPowerVal', { Text = 'Jump Power', Default = 50, Min = 50, Max = 300, Rounding = 0 })

    -- // LOGIC //
    local Sense = Addons.Sense
    Toggles.EspEnabled:OnChanged(function() Sense.teamSettings.enemy.enabled = Toggles.EspEnabled.Value end)
    Toggles.EspBoxes:OnChanged(function() Sense.teamSettings.enemy.box = Toggles.EspBoxes.Value end)
    Toggles.EspNames:OnChanged(function() Sense.teamSettings.enemy.name = Toggles.EspNames.Value end)

    RunService.RenderStepped:Connect(function()
        if not LocalPlayer.Character then return end
        
        -- Crosshair
        if Toggles.Crosshair.Value then
            local Type = Options.CrosshairType.Value
            local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            if Toggles.CrosshairSpin.Value then CrosshairRotation = CrosshairRotation + Options.CrosshairSpinSpeed.Value * 0.01 else CrosshairRotation = 0 end

            if Type == "Line" then
                CrosshairX.Visible = true; CrosshairY.Visible = true
                CrosshairX.Color = Options.CrosshairColor.Value; CrosshairY.Color = Options.CrosshairColor.Value
                CrosshairX.Thickness = Options.CrosshairThickness.Value; CrosshairY.Thickness = Options.CrosshairThickness.Value
                local size = Options.CrosshairSize.Value
                local rad = math.rad(CrosshairRotation); local rad90 = math.rad(CrosshairRotation + 90)
                local dx, dy = size * math.cos(rad), size * math.sin(rad)
                local dx2, dy2 = size * math.cos(rad90), size * math.sin(rad90)
                CrosshairX.From = Center - Vector2.new(dx, dy); CrosshairX.To = Center + Vector2.new(dx, dy)
                CrosshairY.From = Center - Vector2.new(dx2, dy2); CrosshairY.To = Center + Vector2.new(dx2, dy2)
            else CrosshairX.Visible = false; CrosshairY.Visible = false end
        else CrosshairX.Visible = false; CrosshairY.Visible = false end

        -- Aimbot
        if Toggles.ShowFOV.Value and Toggles.AimbotEnabled.Value then
            FOVCircle.Visible = true; FOVCircle.Radius = Options.AimbotFOV.Value; FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36); FOVCircle.Color = Options.FOVColor.Value
        else FOVCircle.Visible = false end

        if Toggles.AimbotEnabled.Value and Options.AimbotKey:GetState() then
            local target = nil
            if Toggles.StickyAim.Value and LockedTarget and LockedTarget.Character and LockedTarget.Character:FindFirstChild("Humanoid") and LockedTarget.Character.Humanoid.Health > 0 then
                target = LockedTarget
            else LockedTarget = nil end
            if not target then target = GetClosestPlayer() end
            
            if target then
                LockedTarget = target
                local part = target.Character[Options.TargetPart.Value]
                local targetPos = part.Position
                if Toggles.Prediction.Value then targetPos = targetPos + (part.AssemblyLinearVelocity * Options.PredAmount.Value) end
                
                if Options.AimbotMethod.Value == "Camera" then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Options.AimbotSmoothing.Value)
                elseif Options.AimbotMethod.Value == "Mouse" then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPos)
                    if onScreen then
                        mousemoverel((pos.X - Mouse.X) * Options.AimbotSmoothing.Value, ((pos.Y + 36) - Mouse.Y) * Options.AimbotSmoothing.Value)
                    end
                elseif Options.AimbotMethod.Value == "Character" then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(targetPos.X, LocalPlayer.Character.HumanoidRootPart.Position.Y, targetPos.Z))
                end
            end
        else LockedTarget = nil end
        
        -- Flight
        if Toggles.FlightEnabled.Value and Options.FlightKey:GetState() and LocalPlayer.Character then
             local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
             if hrp then
                 local lv = hrp:FindFirstChild("FlightLV") or Instance.new("LinearVelocity", hrp)
                 lv.Name = "FlightLV"; lv.MaxForce = 999999; lv.RelativeTo = Enum.ActuatorRelativeTo.World
                 local att = hrp:FindFirstChild("FlightAtt") or Instance.new("Attachment", hrp); att.Name = "FlightAtt"; lv.Attachment0 = att
                 local camCF = Camera.CFrame
                 local moveVec = Vector3.zero
                 if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + camCF.LookVector end
                 if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - camCF.LookVector end
                 if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - camCF.RightVector end
                 if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + camCF.RightVector end
                 if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0,1,0) end
                 if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec = moveVec - Vector3.new(0,1,0) end
                 lv.VectorVelocity = moveVec * Options.FlightSpeed.Value
                 local hold = hrp:FindFirstChild("FlightHold") or Instance.new("BodyVelocity", hrp)
                 hold.Name = "FlightHold"; hold.MaxForce = Vector3.new(0, math.huge, 0); hold.Velocity = Vector3.zero
             end
        else
             if LocalPlayer.Character then
                 local h = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                 if h then
                     if h:FindFirstChild("FlightLV") then h.FlightLV:Destroy() end
                     if h:FindFirstChild("FlightAtt") then h.FlightAtt:Destroy() end
                     if h:FindFirstChild("FlightHold") then h.FlightHold:Destroy() end
                 end
             end
        end
        
        if Toggles.Noclip.Value then
            if Options.NoclipMethod.Value == "Standard" then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            elseif Options.NoclipMethod.Value == "CFrame" then
                if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + LocalPlayer.Character.Humanoid.MoveDirection * 0.5
                end
            end
        end
    end)
    
    -- Setup Settings
    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:ApplyToTab(Tabs.Settings)
end