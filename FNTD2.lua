return function(Window, Library, SaveManager, ThemeManager, Addons, Toggles, Options)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    
    local Tabs = { FNTD = Window:AddTab('FNTD 2'), Settings = Window:AddTab('Settings') }
    local Farm = Tabs.FNTD:AddLeftGroupbox('Auto Farm')
    Farm:AddToggle('FNTD_AutoFarm', { Text = 'Enable Macro', Default = false })
    
    local PlaceCFrame = CFrame.new(1046.0826416015625, 13.74722671508789, -821.7234497070312, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    local UnitGUIDs = {"{5f187a7d-7913-4380-b2e5-8efccc55574d}","{eddb8343-4f60-4d43-b76b-ef3060268c3d}","{dc8fea2e-72b0-42d3-a5e9-9e9abc7311d3}","{8aec151a-a75e-4caa-a8cd-86226136e791}","{7a02a675-61e8-46d0-8fd7-b2bd0a665c6b}"}
    
    local function FindNetPath()
        local Shared = ReplicatedStorage:FindFirstChild("Shared"); if not Shared then return nil end
        local pkgs = Shared:FindFirstChild("Packages"); if not pkgs then return nil end
        local idx = pkgs:FindFirstChild("_Index"); if not idx then return nil end
        for _, c in ipairs(idx:GetChildren()) do if c.Name:match("^sleitnick_net@") then return c:FindFirstChild("net") end end
        return nil
    end

    task.spawn(function()
        while true do
            if Toggles.FNTD_AutoFarm.Value then
                local Net = FindNetPath()
                if Net then
                    local Place = Net:FindFirstChild("RE/PlaceUnit")
                    local Upg = Net:FindFirstChild("RE/UpgradeAll")
                    local Spd = Net:FindFirstChild("RE/UpdateGameSpeed")
                    local Vote = Net:FindFirstChild("RE/VoteEvent") 
                    if Place then for _, guid in ipairs(UnitGUIDs) do pcall(function() Place:FireServer(unpack({{PlaceCFrame = PlaceCFrame, UnitGUID = guid}})) end); task.wait(0.05) end end
                    if Upg then pcall(function() Upg:FireServer() end) end; if Spd then pcall(function() Spd:FireServer() end) end; if Vote then pcall(function() Vote:FireServer("Again") end) end
                end
            end
            task.wait(1)
        end
    end)
    
    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:ApplyToTab(Tabs.Settings)
end