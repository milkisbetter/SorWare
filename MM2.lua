return function(Window, Library, SaveManager, ThemeManager, Addons, Toggles, Options)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    
    local Tabs = { MM2 = Window:AddTab('MM2'), Settings = Window:AddTab('Settings') }
    local CombatBox = Tabs.MM2:AddLeftGroupbox('Combat')
    local MoveBox = Tabs.MM2:AddRightGroupbox('Movement')
    local VisBox = Tabs.MM2:AddRightGroupbox('Visuals')

    CombatBox:AddToggle('MM2_KillAura', { Text = 'Kill Aura (Tool)', Default = false })
    MoveBox:AddToggle('MM2_Speed', { Text = 'Speed Boost', Default = false })
    MoveBox:AddToggle('MM2_HighJump', { Text = 'High Jump', Default = false })
    MoveBox:AddToggle('MM2_Noclip', { Text = 'Noclip', Default = false })
    MoveBox:AddToggle('MM2_InfJump', { Text = 'Infinite Jump', Default = false })
    VisBox:AddToggle('EspEnabled', { Text = 'ESP Enabled', Default = false })
    VisBox:AddToggle('EspBoxes', { Text = 'Boxes', Default = false })
    VisBox:AddToggle('EspNames', { Text = 'Names', Default = false })
    
    task.spawn(function()
        while true do
            if Toggles.MM2_KillAura.Value and LocalPlayer.Character then
                local tool = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") or LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                if tool then
                    local nearest, dist = nil, 15
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local mag = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if mag < dist then dist = mag; nearest = v end
                        end
                    end
                    if nearest then
                        if not LocalPlayer.Character:FindFirstChild(tool.Name) then LocalPlayer.Character.Humanoid:EquipTool(tool) end
                        tool:Activate()
                    end
                end
            end
            task.wait(0.1)
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character then return end
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            if Toggles.MM2_Speed.Value then hum.WalkSpeed = 30 end
            if Toggles.MM2_HighJump.Value then hum.JumpPower = 100 end
        end
        if Toggles.MM2_Noclip.Value then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
        end
    end)
    
    UserInputService.JumpRequest:Connect(function()
        if Toggles.MM2_InfJump.Value and LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
    end)
    
    local Sense = Addons.Sense
    Toggles.EspEnabled:OnChanged(function() Sense.teamSettings.enemy.enabled = Toggles.EspEnabled.Value end)
    Toggles.EspBoxes:OnChanged(function() Sense.teamSettings.enemy.box = Toggles.EspBoxes.Value end)
    Toggles.EspNames:OnChanged(function() Sense.teamSettings.enemy.name = Toggles.EspNames.Value end)
    
    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:ApplyToTab(Tabs.Settings)
end