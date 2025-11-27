--[[
    SORWARE - ULTIMATE EDITION (v23.0)
    UI: Obsidian (Dark/Ubuntu)
    Logic: Universal + Arsenal + FNTD (Priority System) + PF
    Author: Pine (Cell Block D)
]]

-- // 1. SERVICES
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    UserInputService = game:GetService("UserInputService"),
    VirtualUser = game:GetService("VirtualUser"),
    TeleportService = game:GetService("TeleportService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // 0. REJOIN CONFIG
local ScriptURL = "https://raw.githubusercontent.com/milkisbetter/SorWare/main/SorWare.lua" 

-- // 2. LOAD LIBRARIES
local Repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(Repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(Repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(Repo .. 'addons/SaveManager.lua'))()
local Sense = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Sirius/request/library/sense/source.lua'))()

-- Patch Sense
if not Sense.EspInterface then
    Sense.EspInterface = {
        getCharacter = function(Player) return Player.Character end,
        getHealth = function(Character) 
            local Hum = Character and Character:FindFirstChild("Humanoid")
            return Hum and Hum.Health or 100, Hum and Hum.MaxHealth or 100 
        end
    }
end

-- // 3. GAME DETECTION
local PlaceID = game.PlaceId
local GameMode = "Universal"

if PlaceID == 286090429 or PlaceID == 286090429 then 
    GameMode = "Arsenal"
elseif PlaceID == 80550384527033 or PlaceID == 14816132646 then 
    GameMode = "FNTD"
elseif PlaceID == 292439477 or PlaceID == 299659045 then 
    GameMode = "PhantomForces"
end

-- // 4. UI SETUP
local Window = Library:CreateWindow({
    Title = "SorWare | " .. GameMode,
    Center = true, AutoShow = true, TabPadding = 8
})

local Tabs = {
    Game = (GameMode ~= "Universal") and Window:AddTab(GameMode) or nil,
    Combat = Window:AddTab("Combat"),
    Visuals = Window:AddTab("Visuals"),
    Movement = Window:AddTab("Movement"),
    Settings = Window:AddTab("Settings")
}

-- // 5. VISUALS TAB
local ESPGroup = Tabs.Visuals:AddLeftGroupbox("Sense ESP")
ESPGroup:AddToggle("MasterESP", { Text = "Master Switch", Default = false }):OnChanged(function(v)
    Sense.teamSettings.enemy.enabled = v
    if GameMode == "Universal" then Sense.teamSettings.friendly.enabled = v end
    Sense.Load()
end)
ESPGroup:AddToggle("ESPBox", { Text = "Boxes", Default = false }):OnChanged(function(v) Sense.teamSettings.enemy.box = v end)
ESPGroup:AddToggle("ESPName", { Text = "Names", Default = false }):OnChanged(function(v) Sense.teamSettings.enemy.name = v end)
ESPGroup:AddToggle("ESPHealth", { Text = "Health", Default = false }):OnChanged(function(v) Sense.teamSettings.enemy.healthBar = v end)
ESPGroup:AddToggle("ESPTracer", { Text = "Tracers", Default = false }):OnChanged(function(v) Sense.teamSettings.enemy.tracer = v end)

-- // 6. UNIVERSAL COMBAT
local AimbotGroup = Tabs.Combat:AddLeftGroupbox("Aimbot")
AimbotGroup:AddToggle("AimbotEnabled", { Text = "Enabled", Default = false })
AimbotGroup:AddLabel("Keybind"):AddKeyPicker("AimbotKey", { Default = "E", Mode = "Hold", Text = "Aim Key" })
AimbotGroup:AddDropdown("AimbotMethod", { Values = {"Camera", "Mouse"}, Default = 1, Multi = false, Text = "Method" })
AimbotGroup:AddDropdown("TargetPart", { Values = {"Head", "HumanoidRootPart", "Torso"}, Default = 1, Multi = false, Text = "Target Part" })
AimbotGroup:AddSlider("Smoothing", { Text = "Smoothing", Default = 0.5, Min = 0.01, Max = 1, Rounding = 2 })
AimbotGroup:AddToggle("TeamCheck", { Text = "Team Check", Default = true })
AimbotGroup:AddToggle("WallCheck", { Text = "Wall Check", Default = false })

local FOVGroup = Tabs.Combat:AddRightGroupbox("FOV")
FOVGroup:AddToggle("DrawFOV", { Text = "Draw FOV", Default = true }):AddColorPicker("FOVColor", { Default = Color3.fromRGB(255, 255, 255) })
FOVGroup:AddSlider("FOVRadius", { Text = "Radius", Default = 100, Min = 10, Max = 800, Rounding = 0 })

-- // 7. UNIVERSAL MOVEMENT
local MoveGroup = Tabs.Movement:AddLeftGroupbox("Movement")
MoveGroup:AddToggle("FlightEnabled", { Text = "Flight", Default = false }):AddKeyPicker("FlightKey", { Default = "F", Mode = "Toggle", Text = "Toggle Flight" })
MoveGroup:AddSlider("FlightSpeed", { Text = "Flight Speed", Default = 50, Min = 10, Max = 300, Rounding = 0 })
MoveGroup:AddToggle("SpeedHack", { Text = "Speed Hack", Default = false })
MoveGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 0 })
MoveGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MoveGroup:AddToggle("Noclip", { Text = "Noclip", Default = false })

-- // 8. GAME SPECIFIC LOGIC

-- [ ARSENAL ]
if GameMode == "Arsenal" then
    local WepMods = Tabs.Game:AddLeftGroupbox("Weapon Mods")
    WepMods:AddToggle("Ars_NoRecoil", { Text = "No Recoil", Default = false })
    WepMods:AddToggle("Ars_NoSpread", { Text = "No Spread", Default = false })
    WepMods:AddToggle("Ars_RapidFire", { Text = "Rapid Fire", Default = false })
    WepMods:AddToggle("Ars_InfAmmo", { Text = "Infinite Ammo", Default = false })
    WepMods:AddToggle("Ars_Rainbow", { Text = "Rainbow Gun", Default = false })
    
    local HitboxMods = Tabs.Game:AddRightGroupbox("Hitbox Expander")
    HitboxMods:AddToggle("Ars_Hitbox", { Text = "Expand Hitboxes", Default = false })
    HitboxMods:AddSlider("Ars_HitboxSize", { Text = "Size", Default = 13, Min = 2, Max = 25, Rounding = 1 })
    HitboxMods:AddSlider("Ars_HitboxTrans", { Text = "Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 1 })

    task.spawn(function()
        while true do
            if Library.Toggles.Ars_NoRecoil.Value or Library.Toggles.Ars_NoSpread.Value or Library.Toggles.Ars_RapidFire.Value then
                if Services.ReplicatedStorage:FindFirstChild("Weapons") then
                    for _, v in pairs(Services.ReplicatedStorage.Weapons:GetDescendants()) do
                        if Library.Toggles.Ars_NoRecoil.Value and v.Name == "RecoilControl" then v.Value = 0 end
                        if Library.Toggles.Ars_NoSpread.Value and v.Name == "MaxSpread" then v.Value = 0 end
                        if Library.Toggles.Ars_RapidFire.Value and v.Name == "Auto" then v.Value = true end
                        if Library.Toggles.Ars_RapidFire.Value and v.Name == "FireRate" then v.Value = 0.02 end
                    end
                end
            end
            task.wait(2)
        end
    end)
end

-- [ FIVE NIGHTS TD (Priority System) ]
if GameMode == "FNTD" then
    local Farm = Tabs.Game:AddLeftGroupbox('Macro Setup')
    
    Farm:AddInput('MacroX', { Default = '1046', Text = 'Pos X', Numeric = true })
    Farm:AddInput('MacroY', { Default = '13', Text = 'Pos Y', Numeric = true })
    Farm:AddInput('MacroZ', { Default = '-821', Text = 'Pos Z', Numeric = true })
    
    Farm:AddButton('Grab Current Position', function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local Pos = LocalPlayer.Character.HumanoidRootPart.Position
            Library.Options.MacroX:SetValue(tostring(math.floor(Pos.X)))
            Library.Options.MacroY:SetValue(tostring(math.floor(Pos.Y)))
            Library.Options.MacroZ:SetValue(tostring(math.floor(Pos.Z)))
            Library:Notify("Coords Updated", 3)
        end
    end)

    Farm:AddToggle('Recorder', { Text = 'Record Placements', Default = false, Tooltip = 'Fills empty slots with new Units' })
    Farm:AddToggle('FNTD_AutoFarm', { Text = 'Enable Macro', Default = false })
    Farm:AddToggle('AutoRejoin', { Text = 'Reload on Teleport', Default = true })

    LocalPlayer.OnTeleport:Connect(function(State)
        if Library.Toggles.AutoRejoin.Value and queue_on_teleport then
            queue_on_teleport(string.format([[repeat task.wait() until game:IsLoaded(); pcall(function() loadstring(game:HttpGet("%s"))() end)]], ScriptURL))
        end
    end)
    
    -- Priority Slots UI
    local SlotsGroup = Tabs.Game:AddRightGroupbox('Unit Loadout')
    for i = 1, 6 do
        SlotsGroup:AddLabel("Unit " .. i)
        SlotsGroup:AddInput('GUID'..i, { Default = '', Text = 'GUID', Placeholder = 'Waiting...' })
        SlotsGroup:AddSlider('Prio'..i, { Text = 'Priority (1=High)', Default = i, Min = 1, Max = 6, Rounding = 0 })
        SlotsGroup:AddDivider()
    end

    -- Recorder Hook
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if method == "FireServer" and string.find(self.Name, "PlaceUnit") and Library.Toggles.Recorder.Value then
            for _, arg in pairs(args) do
                if type(arg) == "table" and rawget(arg, "UnitGUID") then
                    local DetectedID = arg.UnitGUID
                    local isDuplicate = false
                    for i = 1, 6 do
                        if Library.Options["GUID"..i].Value == DetectedID then isDuplicate = true; break end
                    end
                    
                    if not isDuplicate then
                        for i = 1, 6 do
                            local Opt = Library.Options["GUID"..i]
                            if Opt.Value == "" then
                                Opt:SetValue(DetectedID)
                                Library:Notify("Saved to Slot " .. i, 3)
                                break
                            end
                        end
                    end
                end
            end
        end
        return oldNamecall(self, unpack(args))
    end)
    setreadonly(mt, true)

    -- Priority Macro Loop
    task.spawn(function()
        while true do
            if Library.Toggles.FNTD_AutoFarm.Value then
                local Shared = Services.ReplicatedStorage:FindFirstChild("Shared")
                local Net = nil
                if Shared and Shared:FindFirstChild("Packages") then
                     local Index = Shared.Packages:FindFirstChild("_Index")
                     if Index then
                         for _, c in ipairs(Index:GetChildren()) do
                            if c.Name:match("^sleitnick_net@") then Net = c:FindFirstChild("net"); break end
                         end
                     end
                end

                if Net then
                    local Place = Net:FindFirstChild("RE/PlaceUnit")
                    local Upg = Net:FindFirstChild("RE/UpgradeAll")
                    local Spd = Net:FindFirstChild("RE/UpdateGameSpeed")
                    local Vote = Net:FindFirstChild("RE/VoteEvent") 
                    
                    if Place then 
                        local X = tonumber(Library.Options.MacroX.Value) or 1046
                        local Y = tonumber(Library.Options.MacroY.Value) or 13
                        local Z = tonumber(Library.Options.MacroZ.Value) or -821
                        local TargetCF = CFrame.new(X, Y, Z)
                        
                        -- 1. Collect Valid Units
                        local UnitsToPlace = {}
                        for i = 1, 6 do
                            local ID = Library.Options["GUID"..i].Value
                            local Prio = Library.Options["Prio"..i].Value
                            if ID and ID ~= "" then
                                table.insert(UnitsToPlace, {ID = ID, Priority = Prio})
                            end
                        end
                        
                        -- 2. Sort by Priority (Lower number = First)
                        table.sort(UnitsToPlace, function(a, b) return a.Priority < b.Priority end)
                        
                        -- 3. Execute in Order
                        for _, Unit in ipairs(UnitsToPlace) do
                            pcall(function() 
                                Place:FireServer(unpack({{PlaceCFrame = TargetCF, UnitGUID = Unit.ID}})) 
                            end)
                            task.wait(0.1) -- Placement delay
                        end
                    end
                    
                    if Upg then pcall(function() Upg:FireServer() end) end
                    if Spd then pcall(function() Spd:FireServer() end) end
                    if Vote then pcall(function() Vote:FireServer("Again") end) end
                end
            end
            task.wait(1)
        end
    end)
end

-- // 9. SETTINGS & INIT
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function() Library:Unload(); Sense.Unload() end)
MenuGroup:AddLabel("Menu Key"):AddKeyPicker("MenuKey", { Default = "RightShift", NoUI = true, Text = "Menu Keybind" })

Library.ToggleKeybind = Library.Options.MenuKey

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("SorWare")
SaveManager:SetFolder("SorWare/" .. GameMode)
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- // 10. HELPER LOGIC
local function IsVisible(TargetPart)
    if not TargetPart then return false end
    local Origin = Camera.CFrame.Position
    local Direction = (TargetPart.Position - Origin).Unit * (TargetPart.Position - Origin).Magnitude
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = {LocalPlayer.Character}
    Params.FilterType = Enum.RaycastFilterType.Exclude
    local Result = Services.Workspace:Raycast(Origin, Direction, Params)
    return Result == nil
end

local function GetClosestPlayer()
    local Closest = nil
    local ShortestDist = math.huge
    local MousePos = Vector2.new(Mouse.X, Mouse.Y)
    local FOV = Library.Options.FOVRadius.Value
    
    for _, Plr in pairs(Services.Players:GetPlayers()) do
        if Plr ~= LocalPlayer then
            local Char = Sense.EspInterface.getCharacter(Plr)
            if Char then
                local IsTeam = (Plr.Team == LocalPlayer.Team)
                if GameMode == "Arsenal" and IsTeam then continue end
                if Library.Toggles.TeamCheck.Value and IsTeam then continue end
                
                local Target = Char:FindFirstChild(Library.Options.TargetPart.Value)
                if Target then
                     if not Library.Toggles.WallCheck.Value or IsVisible(Target) then
                        local Pos, OnScreen = Camera:WorldToViewportPoint(Target.Position)
                        if OnScreen then
                            local Dist = (MousePos - Vector2.new(Pos.X, Pos.Y)).Magnitude
                            if Dist < FOV and Dist < ShortestDist then
                                ShortestDist = Dist
                                Closest = Target
                            end
                        end
                     end
                end
            end
        end
    end
    return Closest
end

-- // 11. MAIN LOOP
local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 1; FOVCircle.NumSides = 64; FOVCircle.Filled = false; FOVCircle.Visible = false

Services.RunService.RenderStepped:Connect(function()
    -- FOV
    if Library.Toggles.DrawFOV.Value and Library.Toggles.AimbotEnabled.Value then
        FOVCircle.Visible = true
        FOVCircle.Radius = Library.Options.FOVRadius.Value
        FOVCircle.Color = Library.Options.FOVColor.Value
        FOVCircle.Position = Services.UserInputService:GetMouseLocation()
    else
        FOVCircle.Visible = false
    end

    -- Aimbot
    if Library.Toggles.AimbotEnabled.Value and Library.Options.AimbotKey:GetState() then
        local Target = GetClosestPlayer()
        if Target then
            if Library.Options.AimbotMethod.Value == "Camera" then
                local AimPos = CFrame.new(Camera.CFrame.Position, Target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(AimPos, Library.Options.Smoothing.Value)
            elseif Library.Options.AimbotMethod.Value == "Mouse" then
                local Pos = Camera:WorldToViewportPoint(Target.Position)
                mousemoverel((Pos.X - Mouse.X) * Library.Options.Smoothing.Value, ((Pos.Y + 36) - Mouse.Y) * Library.Options.Smoothing.Value)
            end
        end
    end

    -- Arsenal Logic
    if GameMode == "Arsenal" and Library.Toggles.Ars_Hitbox.Value then
        local Size = Library.Options.Ars_HitboxSize.Value
        local Trans = Library.Options.Ars_HitboxTrans.Value
        for _, v in pairs(Services.Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Team ~= LocalPlayer.Team and v.Character then
                pcall(function()
                    for _, PartName in pairs({"HeadHB", "HumanoidRootPart", "RightUpperLeg", "LeftUpperLeg"}) do
                        local Part = v.Character:FindFirstChild(PartName)
                        if Part then Part.CanCollide = false; Part.Transparency = Trans; Part.Size = Vector3.new(Size, Size, Size) end
                    end
                end)
            end
        end
    end

    if GameMode == "Arsenal" and Library.Toggles.Ars_InfAmmo.Value then
        pcall(function()
            LocalPlayer.PlayerGui.GUI.Client.Variables.ammocount.Value = 999
            LocalPlayer.PlayerGui.GUI.Client.Variables.ammocount2.Value = 999
        end)
    end
    
    if GameMode == "Arsenal" and Library.Toggles.Ars_Rainbow.Value and Camera:FindFirstChild("Arms") then
         for _,v in pairs(Camera.Arms:GetDescendants()) do 
            if v:IsA("MeshPart") then v.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end 
         end
    end
end)

-- // 12. PHYSICS LOOP
Services.RunService.Stepped:Connect(function()
    if not LocalPlayer.Character then return end
    local HRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if Library.Toggles.FlightEnabled.Value and Library.Options.FlightKey:GetState() and HRP then
        local LV = HRP:FindFirstChild("SorWareFlight") or Instance.new("LinearVelocity", HRP)
        LV.Name = "SorWareFlight"; LV.MaxForce = 999999; LV.RelativeTo = Enum.ActuatorRelativeTo.World
        local Att = HRP:FindFirstChild("SorWareAtt") or Instance.new("Attachment", HRP)
        Att.Name = "SorWareAtt"; LV.Attachment0 = Att
        
        local MoveDir = Vector3.zero
        local CamCF = Camera.CFrame
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then MoveDir = MoveDir + CamCF.LookVector end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then MoveDir = MoveDir - CamCF.LookVector end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then MoveDir = MoveDir - CamCF.RightVector end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then MoveDir = MoveDir + CamCF.RightVector end
        
        LV.VectorVelocity = MoveDir * Library.Options.FlightSpeed.Value
        local BV = HRP:FindFirstChild("SorWareHold") or Instance.new("BodyVelocity", HRP)
        BV.Name = "SorWareHold"; BV.MaxForce = Vector3.new(0, math.huge, 0); BV.Velocity = Vector3.zero
    else
        if HRP then
            if HRP:FindFirstChild("SorWareFlight") then HRP.SorWareFlight:Destroy() end
            if HRP:FindFirstChild("SorWareHold") then HRP.SorWareHold:Destroy() end
        end
    end
    
    if Library.Toggles.SpeedHack.Value then
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Hum then Hum.WalkSpeed = Library.Options.WalkSpeed.Value end
    end
    
    if Library.Toggles.Noclip.Value then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

Services.UserInputService.JumpRequest:Connect(function()
    if Library.Toggles.InfJump.Value and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

Library:Notify("SorWare v23.0 Loaded (Priority System)", 5)
