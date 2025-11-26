return function(Window, Library, SaveManager, ThemeManager, Addons) -- FIXED: Removed Toggles, Options args
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    
    local Tabs = { Arsenal = Window:AddTab('Arsenal'), Settings = Window:AddTab('Settings') }
    local Main = Tabs.Arsenal:AddLeftGroupbox('Weapon Mods')
    local Cheat = Tabs.Arsenal:AddRightGroupbox('Exploits')
    local Vis = Tabs.Arsenal:AddRightGroupbox('Visuals')
    
    Main:AddToggle('Ars_NoRecoil', { Text = 'No Recoil', Default = false })
    Main:AddToggle('Ars_NoSpread', { Text = 'No Spread', Default = false })
    Main:AddToggle('Ars_RapidFire', { Text = 'Rapid Fire', Default = false })
    Main:AddToggle('Ars_InfAmmo', { Text = 'Infinite Ammo', Default = false })
    
    Cheat:AddToggle('Ars_Hitbox', { Text = 'Hitbox Expander', Default = false, Tooltip = 'Massive Hitboxes (Blatant)' })
    Cheat:AddSlider('Ars_HitboxSize', { Text = 'Hitbox Size', Default = 13, Min = 1, Max = 21, Rounding = 0 })
    Cheat:AddToggle('Ars_Speed', { Text = 'Speed Hack', Default = false })
    Cheat:AddToggle('Ars_InfJump', { Text = 'Infinite Jump', Default = false })
    
    Vis:AddToggle('EspEnabled', { Text = 'ESP Enabled', Default = false })
    Vis:AddToggle('EspBoxes', { Text = 'Boxes', Default = false })
    Vis:AddToggle('EspNames', { Text = 'Names', Default = false })
    
    task.spawn(function()
        while true do
            if Toggles.Ars_NoRecoil.Value or Toggles.Ars_NoSpread.Value or Toggles.Ars_RapidFire.Value then
                if ReplicatedStorage:FindFirstChild("Weapons") then
                    for _, v in pairs(ReplicatedStorage.Weapons:GetDescendants()) do
                        if Toggles.Ars_NoRecoil.Value and v.Name == "RecoilControl" then v.Value = 0 end
                        if Toggles.Ars_NoSpread.Value and v.Name == "MaxSpread" then v.Value = 0 end
                        if Toggles.Ars_RapidFire.Value and v.Name == "Auto" then v.Value = true end
                        if Toggles.Ars_RapidFire.Value and v.Name == "FireRate" then v.Value = 0.02 end
                    end
                end
            end
            task.wait(2)
        end
    end)

    task.spawn(function()
        while true do
            if Toggles.Ars_InfAmmo.Value then
                pcall(function()
                    local vars = LocalPlayer.PlayerGui.GUI.Client.Variables
                    vars.ammocount.Value = 999; vars.ammocount2.Value = 999
                end)
            end
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        while true do
            if Toggles.Ars_Hitbox.Value then
                local size = Options.Ars_HitboxSize.Value
                for _, v in pairs(Players:GetPlayers()) do
                    if v.Name ~= LocalPlayer.Name and v.Team ~= LocalPlayer.Team and v.Character then
                        for _, p in pairs({"HeadHB", "HumanoidRootPart", "RightUpperLeg", "LeftUpperLeg"}) do
                            local part = v.Character:FindFirstChild(p)
                            if part then
                                part.CanCollide = false
                                part.Transparency = 0.5 
                                part.Size = Vector3.new(size, size, size)
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
    
    LocalPlayer.CharacterAdded:Connect(function(c)
        c:WaitForChild("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Toggles.Ars_Speed.Value then c.Humanoid.WalkSpeed = 100 end
        end)
    end)
    
    UserInputService.JumpRequest:Connect(function()
        if Toggles.Ars_InfJump.Value and LocalPlayer.Character then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
    
    local Sense = Addons.Sense
    Toggles.EspEnabled:OnChanged(function() Sense.teamSettings.enemy.enabled = Toggles.EspEnabled.Value end)
    Toggles.EspBoxes:OnChanged(function() Sense.teamSettings.enemy.box = Toggles.EspBoxes.Value end)
    Toggles.EspNames:OnChanged(function() Sense.teamSettings.enemy.name = Toggles.EspNames.Value end)

    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:ApplyToTab(Tabs.Settings)
end
