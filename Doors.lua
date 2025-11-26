return function(Window, Library, SaveManager, ThemeManager, Addons, Toggles, Options)
    local RunService = game:GetService("RunService")
    local ProximityPromptService = game:GetService("ProximityPromptService")
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    local Tabs = { DOORS = Window:AddTab('DOORS'), Settings = Window:AddTab('Settings') }
    local MainBox = Tabs.DOORS:AddLeftGroupbox('Player')
    local AutoBox = Tabs.DOORS:AddLeftGroupbox('Automation')
    local VisBox = Tabs.DOORS:AddRightGroupbox('Visuals')

    MainBox:AddToggle('Doors_Speed', { Text = 'Speed Boost', Default = false })
    MainBox:AddSlider('Doors_SpeedVal', { Text = 'Speed Amount', Default = 20, Min = 16, Max = 24, Rounding = 0 })
    MainBox:AddToggle('Doors_NoClip', { Text = 'Noclip', Default = false })
    MainBox:AddToggle('Doors_InstantInteract', { Text = 'Instant Interact', Default = false })
    
    AutoBox:AddToggle('Doors_AutoLoot', { Text = 'Auto Loot (Items)', Default = false })
    AutoBox:AddToggle('Doors_AutoWardrobe', { Text = 'Auto Hide', Default = false })
    AutoBox:AddToggle('Doors_AntiScreech', { Text = 'Anti-Screech', Default = false })
    AutoBox:AddToggle('Doors_AutoBreaker', { Text = 'Auto Breaker', Default = false })
    AutoBox:AddToggle('Doors_Minecart', { Text = 'Minecart God Mode', Default = false })

    VisBox:AddToggle('Doors_EntityESP', { Text = 'Entity ESP', Default = false })
    VisBox:AddToggle('Doors_ItemESP', { Text = 'Item ESP', Default = false })
    VisBox:AddToggle('Doors_DoorESP', { Text = 'Door ESP', Default = false })
    VisBox:AddToggle('Doors_HidingESP', { Text = 'Hiding Spot ESP', Default = false })
    
    local function CreateHighlight(obj, color, name)
        if not obj:FindFirstChild("SorWareESP") then
            local h = Instance.new("Highlight")
            h.Name = "SorWareESP"; h.FillColor = color; h.OutlineColor = color; h.Parent = obj
            if name then
                local b = Instance.new("BillboardGui", obj); b.Size = UDim2.new(0,100,0,50); b.AlwaysOnTop = true
                local t = Instance.new("TextLabel", b); t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency=1; t.TextColor3=color; t.Text=name
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        if not LocalPlayer.Character then return end
        if Toggles.Doors_Speed.Value then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = Options.Doors_SpeedVal.Value end
        end
        if Toggles.Doors_NoClip.Value then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
    end)

    ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt) if Toggles.Doors_InstantInteract.Value then fireproximityprompt(prompt) end end)

    task.spawn(function()
        while true do
            if Toggles.Doors_AutoLoot.Value and LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
                        if v:IsA("Model") and (v.Name == "Key" or v.Name == "Gold" or v.Name == "Lighter" or v.Name == "Vitamins" or v.Name == "Lockpick") then
                            if v.PrimaryPart and (v.PrimaryPart.Position - hrp.Position).Magnitude < 15 then
                                local p = v:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if p then fireproximityprompt(p) end
                            end
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)

    workspace.ChildAdded:Connect(function(child)
        if Toggles.Doors_AutoWardrobe.Value and (child.Name == "RushMoving" or child.Name == "AmbushMoving") then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local nearest, dist = nil, 100
                for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                    for _, asset in pairs(room:GetDescendants()) do
                        if asset.Name == "Wardrobe" and asset.PrimaryPart then
                            local d = (asset.PrimaryPart.Position - hrp.Position).Magnitude
                            if d < dist then dist = d; nearest = asset end
                        end
                    end
                end
                if nearest then
                    local prompt = nearest:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then fireproximityprompt(prompt) end
                end
            end
        end
    end)

    workspace.CurrentCamera.ChildAdded:Connect(function(child)
        if Toggles.Doors_AntiScreech.Value and child.Name == "Screech" then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.lookAt(hrp.Position, child.PrimaryPart.Position) end
        end
    end)
    
    task.spawn(function()
         while true do
            if Toggles.Doors_AutoBreaker.Value then
                for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
                    if v.Name == "BreakerSwitch" then
                        local p = v:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if p then fireproximityprompt(p) end
                    end
                end
            end
            if Toggles.Doors_Minecart.Value then
                for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
                    if v.Name == "Seek_Arm" or v.Name == "Chassis" then
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end
            
            -- Visuals
            if Toggles.Doors_EntityESP.Value then
                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name == "RushMoving" or v.Name == "AmbushMoving" or v.Name == "FigureRig" then CreateHighlight(v, Color3.new(1,0,0), v.Name) end
                end
            end
            for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
                for _, v in pairs(room:GetDescendants()) do
                    if Toggles.Doors_ItemESP.Value and (v.Name == "Key" or v.Name == "Lighter" or v.Name == "Lockpick" or v.Name == "Vitamins") then CreateHighlight(v, Color3.new(0,1,0)) end
                    if Toggles.Doors_DoorESP.Value and v.Name == "Door" and v:IsA("Model") then CreateHighlight(v, Color3.new(0,1,1)) end
                    if Toggles.Doors_HidingESP.Value and (v.Name == "Wardrobe" or v.Name == "Bed") then CreateHighlight(v, Color3.new(0.5,0,1)) end
                end
            end
            task.wait(1)
         end
    end)
    
    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:ApplyToTab(Tabs.Settings)
end