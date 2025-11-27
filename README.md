# SorWare - Ultimate Script Hub

![Version](https://img.shields.io/badge/Version-25.0-blue) ![Status](https://img.shields.io/badge/Status-Undetected-green) ![UI](https://img.shields.io/badge/UI-Obsidian-purple)

**SorWare** is a high-performance, multi-game script hub developed in Lua. Designed for stability and speed, it features a sleek Obsidian (Dark/Ubuntu) interface, optimized global logic loops, and a robust **Plugin System** that allows the community to expand the hub's capabilities without modifying the core source.

## 🎮 Built-In Support

SorWare automatically detects the game you are playing and loads the appropriate module.

*   **Universal:** Aimbot, Sense ESP (Box, Name, Health, Tracers), Flight, Noclip, Speed Hack, Infinite Jump.
*   **Arsenal:** Visuals-Safe Hitbox Expander, Silent Aim (No Recoil/Spread), Infinite Ammo, Rainbow Gun.
*   **Five Nights TD:** Advanced Macro with Position Recorder, Priority Unit Placement, and Auto-Rejoin.
*   **Phantom Forces:** Silent Aim and No Recoil hooks.

---

# 🔌 Plugin System Documentation

SorWare v25.0+ introduces a dynamic Plugin API. This allows developers to create extensions, add support for new games, or create entirely new UI windows using the internal SorWare framework.

## Getting Started

To create a plugin, you must understand how SorWare exposes its internal API to the global environment. All core variables are stored in `getgenv().SorWare`.

### The Global API Table

| Variable | Type | Description |
| :--- | :--- | :--- |
| `SorWare.Library` | `Table` | The active Obsidian UI Library instance. Used to create elements. |
| `SorWare.Window` | `Object` | The main SorWare UI Window. Use this to add tabs to the main menu. |
| `SorWare.Tabs` | `Table` | A list of existing tabs (`Combat`, `Visuals`, `Movement`, `Game`). |
| `SorWare.Services` | `Table` | Pre-fetched Roblox Services (`Players`, `Workspace`, `ReplicatedStorage`, etc.). |
| `SorWare.Sense` | `Table` | The active ESP Library instance. |
| `SorWare.LocalPlayer` | `Instance` | Shortcut for `game.Players.LocalPlayer`. |

---

## 🛠️ Plugin Types (Headers)

When writing a plugin, the **first line of your script** determines how SorWare handles it.

### 1. Game Support Plugin
Adds features to the existing SorWare window. Use this if you are adding hacks for a game SorWare is already running in.
```lua
-- plugintype = gamesupport
2. Custom Window Plugin
Creates a completely separate UI window. Use this if you want to build a full interface for a game SorWare doesn't support natively.
code
Lua
-- plugintype = customwindow
📖 UI Reference Guide
SorWare uses a modified Obsidian/Linoria library. Below is the documentation on how to create every type of UI element in your plugin.
1. Creating Tabs & Groups
Only needed if you aren't using existing tabs.
code
Lua
-- Get the Window
local Window = getgenv().SorWare.Window

-- Create a new Tab
local MyTab = Window:AddTab('My Plugin')

-- Create a Groupbox (The container for elements)
-- Side can be 'Left' or 'Right'
local MySection = MyTab:AddLeftGroupbox('Main Features')
2. Adding Toggles
Toggles are used for boolean (true/false) features.
code
Lua
MySection:AddToggle('GodMode', {
    Text = 'God Mode',
    Default = false, -- true or false
    Tooltip = 'Makes you invincible' -- Optional hover text
}):OnChanged(function(value)
    print("God Mode is now:", value)
end)
Note: The first argument ('GodMode') must be a unique index string.
3. Adding Sliders
Sliders allow users to select a number within a range.
code
Lua
MySection:AddSlider('WalkSpeed', {
    Text = 'Walk Speed',
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0, -- 0 for integers, 1 for 0.1, etc.
    Compact = false -- Set to true for a smaller look
}):OnChanged(function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
4. Adding Dropdowns
Useful for selecting modes or target parts.
code
Lua
MySection:AddDropdown('TargetPart', {
    Values = { 'Head', 'Torso', 'Legs' },
    Default = 1, -- Index of the default value ('Head')
    Multi = false, -- Set to true to allow selecting multiple options
    Text = 'Target Part'
}):OnChanged(function(value)
    print("Selected:", value)
end)
5. Adding Labels (Text)
Display information or status text.
code
Lua
MySection:AddLabel('Status: Active')
-- Or with a specific color:
MySection:AddLabel('Warning: Risky Feature'):AddColorPicker('WarnColor', { Default = Color3.fromRGB(255, 0, 0) })
6. Adding Inputs (Text Boxes)
Allow the user to type strings or numbers.
code
Lua
MySection:AddInput('CustomMessage', {
    Default = 'Hello World',
    Text = 'Chat Spam Message',
    Numeric = false, -- Set to true to only allow numbers
    Finished = true, -- Only fires callback when user presses Enter
    Placeholder = 'Type here...'
}):OnChanged(function(text)
    print("User typed:", text)
end)
7. Adding Buttons
Buttons execute a function once when clicked.
code
Lua
MySection:AddButton('Kill All', function()
    -- Your kill logic here
    print("Killed everyone!")
end)
8. Adding Keybinds
Allow users to toggle features with a keyboard press.
code
Lua
-- You usually attach this to a Toggle or a Label
MySection:AddLabel('Aimbot Key'):AddKeyPicker('AimKey', {
    Default = 'MB2', -- Right Mouse Button
    SyncToggleState = false, 
    Mode = 'Hold', -- 'Hold', 'Toggle', or 'Always'
    Text = 'Aimbot Key', -- Text shown in Keybinds menu
    NoUI = false -- Set to true to hide from the Keybinds menu
})

-- Checking the state in a loop:
-- local isPressed = Options.AimKey:GetState()
⚠️ Do's and Don'ts
✅ DO:
Use Unique Indexes: When creating Toggles or Sliders, the first string argument (e.g., 'MyToggle') must be unique across the entire script. If you use an ID that SorWare already uses (like 'AimbotEnabled'), you will overwrite the core settings.
Use pcall: Wrap risky code (like accessing Character parts) in pcall functions to prevent your plugin from crashing the entire hub.
Use task.spawn: If you are running a while true do loop, wrap it in task.spawn so you don't freeze the UI.
❌ DON'T:
Don't Create New Windows for Game Support: If you are making an addon for Arsenal, use -- plugintype = gamesupport and add to the existing window. Do not spawn a second window; it looks messy and confusing.
Don't Touch SorWare.Services: You can read from it, but do not modify the services table or remove items from it.
Don't Rely on Wait(): Use task.wait() for faster and more reliable timing.
💡 Example Plugins
Example 1: Simple Speed Plugin (Game Support)
Copy this into a raw link to test.
code
Lua
-- plugintype = gamesupport

local Library = getgenv().SorWare.Library
local Window = getgenv().SorWare.Window

-- Add a new tab to SorWare
local MyTab = Window:AddTab("My Extra Mods")
local Section = MyTab:AddLeftGroupbox("Player Mods")

Section:AddToggle('SuperJump', { Text = 'Super Jump', Default = false })
Section:AddSlider('JumpPower', { Text = 'Jump Power', Default = 50, Min = 50, Max = 500, Rounding = 0 })

local Services = getgenv().SorWare.Services
local LocalPlayer = Services.Players.LocalPlayer

Services.RunService.RenderStepped:Connect(function()
    if Library.Toggles.SuperJump.Value and LocalPlayer.Character then
        local Hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Hum then
            Hum.UseJumpPower = true
            Hum.JumpPower = Library.Options.JumpPower.Value
        end
    end
end)
Example 2: Custom HUD (Custom Window)
Creates a small separate window.
code
Lua
-- plugintype = customwindow

local Library = getgenv().SorWare.Library

local MiniWindow = Library:CreateWindow({
    Title = "Mini HUD",
    Center = true,
    AutoShow = true,
    TabPadding = 4,
    Size = UDim2.fromOffset(300, 200)
})

local Tab = MiniWindow:AddTab("Main")
local Group = Tab:AddLeftGroupbox("Info")

Group:AddLabel("FPS: 60")
Group:AddLabel("Ping: 45ms")
Group:AddButton("Close HUD", function() MiniWindow:Unload() end)
code
Code
