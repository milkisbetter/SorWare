--[[
    SORWARE - THE WARDEN v5.0 (Stealth Mode)
    Logic: Pre-Ban Check -> Key Validation -> Silent Log -> Approval Poll
    UI: Obsidian (Clean)
]]

local Configuration = {
    -- PASTE YOUR RAW GIST LINK (database.json)
    Database = "https://gist.githubusercontent.com/milkisbetter/a6480e276d654b8d27f9f0eec0277e1c/raw/database.json",
    
    -- PASTE YOUR DISCORD WEBHOOK
    Webhook = "https://discordapp.com/api/webhooks/1443500834590818376/4U-6ilCaSiRZ0eMZ7roCVBHoND_6kFpMk0aZNHbmVMyhceRTVqC3oDf93jKhUraYGAZF",
    
    -- PASTE THE MAIN SCRIPT LINK
    Source = "https://gist.githubusercontent.com/milkisbetter/47b7b62cacefb4927a93d81b56a5616c/raw/walkinghumanoidfly.lua"
}

-- // SERVICES
local Services = { 
    Players = game:GetService("Players"), 
    Http = game:GetService("HttpService"), 
    CoreGui = game:GetService("CoreGui"), 
    RbxAnalytics = game:GetService("RbxAnalyticsService"), 
    TweenService = game:GetService("TweenService") 
}
local LocalPlayer = Services.Players.LocalPlayer
local RequestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local MyHWID = (gethwid and gethwid()) or Services.RbxAnalytics:GetClientId()

-- // 0. PRE-LOAD BAN CHECK (Silent)
-- This runs before any UI is shown.
local Success, Response = pcall(function()
    return game:HttpGet(Configuration.Database .. "?t=" .. tostring(math.random(1, 1000000)))
end)

if Success then
    Response = Response:gsub("^%s+", ""):gsub("%s+$", "")
    local DB = Services.Http:JSONDecode(Response)
    
    if table.find(DB.banned_users, tostring(LocalPlayer.UserId)) or table.find(DB.banned_hwids, MyHWID) then
        -- Silent Kick
        LocalPlayer:Kick("clowny ass nerd got banned")
        task.wait(10)
        return -- Stop script
    end
else
    -- If DB fails to load, we can't verify bans, so we proceed cautiously or error out.
    -- Proceeding to UI but it will fail at button click anyway.
end

-- // UI CONSTRUCTION (Clean Obsidian)
if Services.CoreGui:FindFirstChild("SorWareLogin") then Services.CoreGui.SorWareLogin:Destroy() end

local Screen = Instance.new("ScreenGui")
Screen.Name = "SorWareLogin"
Screen.Parent = Services.CoreGui
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 360, 0, 180)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = Screen

local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 6); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Color = Color3.fromRGB(45, 45, 45); MainStroke.Thickness = 1; MainStroke.Parent = MainFrame

-- Accent
local Accent = Instance.new("Frame"); Accent.Size = UDim2.new(1, 0, 0, 2); Accent.BackgroundColor3 = Color3.fromRGB(119, 56, 255); Accent.Parent = MainFrame
local AccentCorner = Instance.new("UICorner"); AccentCorner.CornerRadius = UDim.new(0, 6); AccentCorner.Parent = Accent

-- Title (Changed)
local Title = Instance.new("TextLabel")
Title.Text = "SorWare | Login" -- Removed "Gatekeeper"
Title.Font = Enum.Font.Ubuntu
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Input
local InputContainer = Instance.new("Frame"); InputContainer.Size = UDim2.new(1, -24, 0, 36); InputContainer.Position = UDim2.new(0, 12, 0, 50); InputContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35); InputContainer.Parent = MainFrame
local InputCorner = Instance.new("UICorner"); InputCorner.CornerRadius = UDim.new(0, 4); InputCorner.Parent = InputContainer
local InputStroke = Instance.new("UIStroke"); InputStroke.Color = Color3.fromRGB(50, 50, 50); InputStroke.Thickness = 1; InputStroke.Parent = InputContainer

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -20, 1, 0); KeyBox.Position = UDim2.new(0, 10, 0, 0); KeyBox.BackgroundTransparency = 1
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255); KeyBox.PlaceholderText = "Enter License Key"; KeyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyBox.Font = Enum.Font.Ubuntu; KeyBox.TextSize = 14; KeyBox.Text = ""; KeyBox.Parent = InputContainer

-- Status
local Status = Instance.new("TextLabel")
Status.Text = "Ready."
Status.Size = UDim2.new(1, -24, 0, 20); Status.Position = UDim2.new(0, 12, 0, 90); Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(100, 100, 100); Status.Font = Enum.Font.Ubuntu; Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left; Status.Parent = MainFrame

-- Button
local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(1, -24, 0, 32); Btn.Position = UDim2.new(0, 12, 1, -44); Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Btn.Text = "Connect"; Btn.Font = Enum.Font.Ubuntu; Btn.TextSize = 14; Btn.TextColor3 = Color3.fromRGB(255, 255, 255); Btn.AutoButtonColor = false; Btn.Parent = MainFrame
local BtnCorner = Instance.new("UICorner"); BtnCorner.CornerRadius = UDim.new(0, 4); BtnCorner.Parent = Btn
local BtnStroke = Instance.new("UIStroke"); BtnStroke.Color = Color3.fromRGB(60, 60, 60); BtnStroke.Thickness = 1; BtnStroke.Parent = Btn

Btn.MouseEnter:Connect(function() Services.TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play() end)
Btn.MouseLeave:Connect(function() Services.TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play() end)

-- // LOGIC HELPERS
local function Log(Title, Color, Fields)
    if RequestFunc then
        RequestFunc({
            Url = Configuration.Webhook, Method = "POST", Headers = {["Content-Type"] = "application/json"},
            Body = Services.Http:JSONEncode({["embeds"] = {{["title"] = Title, ["color"] = Color, ["fields"] = Fields, ["footer"] = {["text"] = "SorWare"}}}})
        })
    end
end

local function StartKillswitch(Key)
    task.spawn(function()
        while true do
            wait(30)
            local S, R = pcall(function() return game:HttpGet(Configuration.Database .. "?t=" .. math.random(1,1000000)) end)
            if S then
                R = R:gsub("^%s+", ""):gsub("%s+$", "")
                local DB = Services.Http:JSONDecode(R)
                local Banned = table.find(DB.banned_users, tostring(LocalPlayer.UserId)) or table.find(DB.banned_hwids, MyHWID)
                local Active = table.find(DB.live_sessions, Key)
                if Banned or not Active then
                    LocalPlayer:Kick("Connection Lost.")
                    break
                end
            end
        end
    end)
end

-- // AUTH FLOW
Btn.MouseButton1Click:Connect(function()
    local InputKey = KeyBox.Text
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.Text = "Connecting..." -- Generic loading text
    Btn.Visible = false
    
    -- 1. Fetch DB
    local Success, Response = pcall(function() return game:HttpGet(Configuration.Database .. "?t=" .. math.random(1,1000000)) end)
    
    if not Success then
        Status.Text = "Connection Error."
        Btn.Visible = true
        return
    end
    
    Response = Response:gsub("^%s+", ""):gsub("%s+$", "")
    local DB = Services.Http:JSONDecode(Response)
    
    -- 2. Validate Key Locally (Does it exist?)
    -- This prevents spamming your webhook with garbage keys
    if DB.keys[InputKey] == nil then
        Status.TextColor3 = Color3.fromRGB(255, 50, 50)
        Status.Text = "Invalid License Key."
        wait(1)
        Btn.Text = "Retry"
        Btn.Visible = true
        return
    end
    
    -- 3. Notify Admin (Silent to user)
    Status.Text = "Verifying..." -- Still looks like loading to user
    Log("🛑 LOGIN REQUEST", 16776960, {
        {["name"]="User",["value"]=LocalPlayer.Name,["inline"]=true},
        {["name"]="Key",["value"]=InputKey,["inline"]=true},
        {["name"]="Action",["value"]="Type `!review "..InputKey.."` to handle.",["inline"]=false}
    })
    
    -- 4. Poll Loop (The Fake Load)
    local Attempts = 0
    local LoadingAnim = {".", "..", "..."}
    
    while Attempts < 40 do -- 120 seconds timeout
        wait(3)
        Attempts = Attempts + 1
        
        -- fake loading animation
        Status.Text = "Verifying" .. LoadingAnim[(Attempts % 3) + 1]
        
        local S, R = pcall(function() return game:HttpGet(Configuration.Database .. "?t=" .. math.random(1,1000000)) end)
        if S then
            R = R:gsub("^%s+", ""):gsub("%s+$", "")
            local NewDB = Services.Http:JSONDecode(R)
            
            -- Check Ban (Silent Kick)
            if table.find(NewDB.banned_hwids, MyHWID) then
                LocalPlayer:Kick("Connection Terminated.")
                return
            end
            
            -- Check Approval
            if table.find(NewDB.live_sessions, InputKey) then
                -- Check Lock
                local SavedHWID = NewDB.keys[InputKey]
                if SavedHWID == "" or SavedHWID == MyHWID then
                    Status.TextColor3 = Color3.fromRGB(0, 255, 100)
                    Status.Text = "Connected."
                    Log("✅ SESSION STARTED", 65280, {{["name"]="User",["value"]=LocalPlayer.Name}})
                    
                    wait(0.5)
                    Services.TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
                    wait(0.5)
                    Screen:Destroy()
                    
                    StartKillswitch(InputKey)
                    loadstring(game:HttpGet(Configuration.Source))()
                    return
                else
                    Status.TextColor3 = Color3.fromRGB(255, 50, 50)
                    Status.Text = "License in use by another device."
                    break
                end
            end
        end
    end
    
    Status.TextColor3 = Color3.fromRGB(255, 50, 50)
    Status.Text = "Connection Timed Out."
    Btn.Text = "Retry"
    Btn.Visible = true
end)
